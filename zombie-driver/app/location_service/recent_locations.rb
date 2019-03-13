# frozen_string_literal: true

require 'import'

module LocationService
  class RecentLocations
    include Dry::Monads::Result::Mixin

    include Import['location_service.client']
    include Import['http_client.url_encoder']

    def call(id:, minutes:)
      path = path(id)
      client.get(path: path, params: { minutes: minutes }).bind do |response_hash|
        Success(
          Types::RecentLocations.new(
            locations: response_hash,
            user_id: id,
            minutes: minutes
          )
        )
      end
    end

    private

    def path(id)
      "/drivers/#{url_encoder.call(id)}/locations"
    end
  end
end
