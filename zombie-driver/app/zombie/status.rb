# frozen_string_literal: true

require 'import'

module Zombie
  class Status
    include Dry::Monads::Result::Mixin

    include Import['geo.distance_traveled']
    include Import[default_threshold: 'zombie.constants.distance_in_meters_threshold']

    def call(location_list:, distance_threshold: nil)
      distance_threshold ||= default_threshold

      return Failure(:no_data) if location_list.empty?
      return Failure(:not_enough_data) if location_list.size == 1

      Success(
        distance_traveled.call(locations: location_list) < distance_threshold
      )
    end
  end
end
