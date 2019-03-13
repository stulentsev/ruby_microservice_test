RSpec.describe 'Geo::Distance' do
  let(:distance) { Application['geo.distance'] }

  let(:from) {
    Types::Location.new(
      latitude: 48.864193,
      longitude: 2.350498
    )
  }

  let(:to) {
    Types::Location.new(
      latitude: 48.863921,
      longitude: 2.349211
    )
  }

  it 'returns the distance in meters' do
    expect(distance.call(from: from, to: to).to_i).to eq(98)
  end
end
