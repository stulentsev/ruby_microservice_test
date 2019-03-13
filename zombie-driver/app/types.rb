# frozen_string_literal: true

# Value objects namespace
module Types
  include Dry::Types.module

  class Location < Dry::Struct::Value
    transform_keys(&:to_sym)

    attribute :latitude, Types::Params::Float
    attribute :longitude, Types::Params::Float

    attribute :updated_at, Types::Params::Time.optional.default(nil)
  end

  LocationList = Types::Strict::Array.of(Location)

  class RecentLocations < Dry::Struct::Value
    transform_keys(&:to_sym)

    attribute :locations, LocationList

    attribute :user_id, Types::Strict::Integer | Types::Strict::String
    attribute :minutes, Types::Strict::Integer
  end
end
