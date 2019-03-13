# frozen_string_literal: true

require 'import'

module Persistence
  class LocationRepo
    include Import['persistence.pool']

    include Import['persistence.max_events_per_owner']
    include Import['persistence.id_hasher']

    # Store a location event in a redis Sorted Set
    #
    # The score is the the unix timestamp ( with seconds precision ) of when
    # we received the event
    #
    # The value is "latitude,longitude,timestamp"
    #
    # We need to store the timestamp otherwise we can't have two events with
    # different timestamps in the same location
    def record_event(location_event, max_len: max_events_per_owner)
      score = location_event.received_at.to_i
      data = to_redis(event: location_event)
      key = key_name_for_user_id(location_event.user_id)

      pool.with do |redis|
        # add the event
        redis.zadd(key, [score, data])

        # Trim the collection.
        # Remove 1 element over our limit every time we insert a new element.
        # Specifically always remove the Nth most recent even, or the event
        # that was recorded N times ago.
        #
        # ZREMRANGEBYRANK Removes all elements in the sorted set stored at key
        # with rank between start and stop. Both start and stop are 0 -based
        # indexes with 0 being the element with the lowest score. These indexes
        # can be negative numbers, where they indicate offsets starting at the
        # element with the highest score. For example: -1 is the element with
        # the highest score, -2 the element with the second highest score and
        # so forth.
        #
        # 0 - lowest score, or oldest
        # -1 - highest score, or newest
        #
        # -(max_size + 2) -> is the element with index [max_size + 1] in
        #                    ascending score order, or the N-th + 1 newest
        # -(max_size + 1) -> is the element with index [max_size + 2] in
        #                    ascending score order or the N-th + 2 newest
        redis.zremrangebyrank(key, -(max_len + 2), -(max_len + 1)) if max_len
      end

      self
    end

    def user_events_count(user_id:)
      pool.with { |redis| redis.zcard(key_name_for_user_id(user_id)) }
    end

    def last_update(user_id:)
      result = pool.with do |redis|
        # -1 is redis special value for last element:
        # range is [last el] -> [last el]
        redis.zrange(key_name_for_user_id(user_id), -1, -1)
      end

      return ::Types::NullLocationRecord.new if result.empty?

      from_redis(string: result[0])
    end

    # Returns a chronological order of location *change* events received.
    #
    # We store every single event, but we only care about location changes.
    #
    # We limit the number of events fetched by 1 per second. Unfortunately our
    # value does not protect from malicious data. As multiple set elements may
    # have the same score.
    def recent_locations_for_user(user_id:, seconds:)
      min_score = Time.now.to_i - seconds
      skip = 0
      # specifcy a fetch limit, just in case we get a bunch of bad events.
      limit = seconds

      events = pool.with do |redis|
        redis.zrangebyscore(
          # +inf is special value meaning the max score in the sorted set
          key_name_for_user_id(user_id), min_score, '+inf', limit: [skip, limit]
        )
      end

      events.
        # wrap the data in a struct casting values from raw storage
        map { |e| from_redis(string: e) }.
        # merge consequtive duplicate locations
        chunk_while { |prev, curr| prev.latitude == curr.latitude && prev.longitude == curr.longitude }.
        # get only the first timestamp of a new location. or the time we received
        # the original location change event
        map(&:first)
    end

    private

    def to_redis(event:)
      "#{event.latitude},#{event.longitude},#{event.received_at.to_i}"
    end

    def from_redis(string:)
      latitude, longitude, timestamp = string.split(',')

      Types::LocationUpdate.new(
        latitude: latitude.to_f,
        longitude: longitude.to_f,
        updated_at: Time.at(timestamp.to_i).utc
      )
    end

    def key_name_for_user_id(id)
      "user_locations:#{id_hasher.call(id.to_s)}"
    end
  end
end
