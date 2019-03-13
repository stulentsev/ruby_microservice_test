# frozen_string_literal: true

RSpec.describe 'Geo::DistanceTraveled' do
  let(:distance_action) { Application['geo.distance_traveled'] }

  let(:distance) { distance_action.call(locations: locations) }

  let(:location_a) {
    Types::Location.new(
      latitude: 48.864193,
      longitude: 2.350498
    )
  }

  let(:location_b) {
    Types::Location.new(
      latitude: 48.863921,
      longitude: 2.349211
    )
  }

  context 'no locations' do
    let(:locations) { nil }

    it { expect(distance).to eq(0) }
  end

  context 'empty locations' do
    let(:locations) { [] }

    it { expect(distance).to eq(0) }
  end

  context 'one location' do
    let(:locations) { [1] }

    it { expect(distance).to eq(0) }
  end

  context 'two locations' do
    let(:locations) { Types::LocationList[[location_a, location_b]] }

    it 'calculates the distance' do
      expect(distance).to be_within(1.0).of(98.97189865220952)
    end
  end

  context 'going between the same two points multiple times' do
    let(:times) { 10 }
    let(:original_locations) { [location_a, location_b] }

    let(:locations) { Types::LocationList[(original_locations * times).flatten] }
    let(:original_distance) { distance_action.call(locations: original_locations) }

    it 'calculates the distance' do
      expect(distance).to be_within(1.0).of(original_distance * ((times * 2) - 1))
      expect(distance).to be_within(1.0).of(1880.4660743919815) # or ~98.97 * 10times * 2 points - 1
    end
  end

  context 'staying at the same location' do
    let(:locations_aab) { Types::LocationList[[location_a, location_a, location_b]] }
    let(:distance_aab) { distance_action.call(locations: locations_aab) }

    let(:locations_ab) { Types::LocationList[[location_a, location_b]] }
    let(:distance_ab) { distance_action.call(locations: locations_ab) }

    it 'is the same distance as between two different' do
      expect(distance_aab).to eq(distance_ab)
    end

  end
end
