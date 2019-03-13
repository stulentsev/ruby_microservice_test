# frozen_string_literal: true

# Value objects namespace
module Types
  include Dry::Types.module

  # Value object for location events received
  class LocationEvent < Dry::Struct::Value
    attribute :latitude, Types::Strict::Float
    attribute :longitude, Types::Strict::Float

    attribute :user_id, Types::Strict::Integer | Types::Strict::String

    attribute :received_at, Types::Strict::Time
  end
  class NullLocationEvent < Dry::Struct::Value; end

  # Value object for location updates requested
  class LocationUpdate < Dry::Struct::Value
    attribute :latitude, Types::Strict::Float
    attribute :longitude, Types::Strict::Float

    attribute :updated_at, Types::Strict::Time
  end

  class NullLocationRecord < Dry::Struct::Value; end
end
