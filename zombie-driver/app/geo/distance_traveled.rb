# frozen_string_literal: true

require 'import'

module Geo
  class DistanceTraveled
    include Import['geo.distance']

    def call(locations:)
      return 0 if !locations || locations.size <= 1

      total = 0

      locations.each_cons(2) do |prev, current|
        total += distance.call(from: prev, to: current)
      end

      total
    end
  end
end
