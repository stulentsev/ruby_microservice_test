# frozen_string_literal: true

Application.boot(:persistence) do |container|
  start do
    require 'redis'
    require 'connection_pool'
    require 'digest'

    use :logger

    # Store maximum of a day(24h) of updates in a stream given that we get
    # an update every second
    container.register('persistence.max_events_per_owner', 60 * 60 * 24)

    # digest function to use to store external ids in the DB
    #
    # It has two concerns:
    #
    # 1. Normalize external ID to be comaptible with optimal redis key structure
    #
    # When receiving external IDs we have no guarantees of the format, and we
    # don't want to restrict users with a specific format. This makes sure that
    # we can store and fetch any ID format used.
    #
    # 2. Decouple specifc external IDs from the location data we store.
    #
    # In terms of privacy we want to make sure that if our location data is
    # exposed for whatever reason - the locations can't be traced to their owner
    # without an external mapping of owner <-> user.
    #
    # Only time the application has the mapping is runtime, as it processes
    # requests. The link |real user <-> location owner| is never persisted.
    #
    container.register('persistence.id_hasher', call: false) do |value|
      Digest::SHA256.hexdigest(value)
    end

    container.register('persistence.connection_provider') do
      url = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/0')
      url = ENV.fetch('REDIS_TEST_URL', 'redis://127.0.0.1:6379/3') if container.config.env == 'test'

      Redis.new(url: url, logger: logger)
    end

    container.register('persistence.pool', cache: true) do
      ConnectionPool.new(size: 5) { container['persistence.connection_provider'] }
    end

    container.register('persistence.drop_db', call: false) do
      container.resolve('persistence.pool').with(&:flushdb)
    end
  end
end
