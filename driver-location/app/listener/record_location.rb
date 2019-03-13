# frozen_string_literal: true

require 'import'
require 'types'

module Listener
  class RecordLocation
    include Dry::Transaction
    include Import['persistence.location_repo']

    step :validate
    # catch any persistance error
    try :persist, catch: StandardError

    RecordLocationCommandSchema = Dry::Validation.Params do
      # some super rough values for lat/lon boundries
      # mostly protecs from overflowing with bad data
      required(:latitude).filled(:float?, gteq?: -90.0, lteq?: 90.0)
      required(:longitude).filled(:float?, gteq?: -180.0, lteq?: 180.0)

      # we don't care too much about the user_id we write in the DB
      # we hash the value before we hit the data
      required(:id).filled { int? | str? }

      required(:timestamp).filled(:time?)
    end

    def validate(input)
      RecordLocationCommandSchema.call(input).to_monad
    end

    def persist(input)
      location_event = ::Types::LocationEvent.new(
        latitude: input[:latitude],
        longitude: input[:longitude],
        user_id: input[:id],
        received_at: input[:timestamp]
      )

      Success(location_repo.record_event(location_event))
    end
  end
end
