# frozen_string_literal: true

require 'import'
module Web
  class RecentLocations
    include Dry::Transaction
    include Import['persistence.location_repo']

    QueryRecentLocationsCommandSchema = Dry::Validation.Params do
      required(:minutes) do
        filled? & int? & gt?(0) & lt?(Application['web.max_minutes_query'])
      end

      # we don't care too much about the user_id we request from the DB
      # we hash the value before we hit the data
      required(:user_id).filled { int? | str? }
    end

    step :validate
    step :fetch_location_records

    def validate(params)
      QueryRecentLocationsCommandSchema.call(params).to_monad
    end

    def fetch_location_records(params)
      Success(
        location_repo.recent_locations_for_user(
          user_id: params[:user_id],
          seconds: params[:minutes] * 60
        ).map do |location_record|
          res = {}
          res[:latitude] = location_record.latitude
          res[:longitude] = location_record.longitude
          res[:updated_at] = location_record.updated_at.iso8601
          res
        end
      )
    end
  end
end
