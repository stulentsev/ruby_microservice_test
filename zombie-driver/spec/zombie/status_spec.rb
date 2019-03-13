# frozen_string_literal: true

RSpec.describe 'Zombie::Status' do
  let(:described_class) { Application['zombie.status'] }

  subject(:status) {
    described_class.call(location_list: locations, distance_threshold: distance_threshold)
  }

  let(:distance_traveled) { 10 }

  let!(:distance_traveled_double) do
    object_double(Application['geo.distance_traveled'], call: distance_traveled)
  end

  before { Application.stub('geo.distance_traveled', distance_traveled_double) }
  after  { Application.unstub('geo.distance_traveled') }

  let(:distance_threshold) { 5 }

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

  let(:locations) { Types::LocationList[[location_a, location_b]] }

  context 'no distance_threshold' do

    before { Application.stub('zombie.constants.distance_in_meters_threshold', distance_traveled + 1) }
    after  { Application.unstub('zombie.constants.distance_in_meters_threshold') }

    let(:distance_threshold) { nil }

    it 'defaults it' do
      expect(status.value!).to eq(true)
    end
  end

  context 'no data' do
    let(:locations) { [] }

    it { expect(status.failure).to eq(:no_data) }
  end

  context 'one location' do
    let(:locations) { Types::LocationList[[location_a]] }

    it { expect(status.failure).to eq(:not_enough_data) }
  end

  context 'traveled more than the min distance' do
    let(:distance_threshold) { distance_traveled - 1 }

    it 'is a zombie' do
      expect(status.value!).to eq(false)
    end
  end

  context 'traveled less than the min distance' do
    let(:distance_threshold) { distance_traveled + 1 }

    it 'is not a zombie' do
      expect(status.value!).to eq(true)
    end
  end

  context 'traveled exactly the min distance' do
    let(:distance_threshold) { distance_traveled }

    it 'is not a zombie' do
      expect(status.value!).to eq(false)
    end
  end

end
