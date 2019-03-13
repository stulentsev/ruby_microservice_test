# frozen_string_literal: true

RSpec.describe 'LocationService::RecentLocations' do
  let(:recent_locations_service) { Application['location_service.recent_locations'] }

  let(:id) { 1 }
  let(:minutes) { 5 }
  subject(:recent_locations) { recent_locations_service.call(id: id, minutes: minutes) }

  let!(:client_double) { object_double(Application['location_service.client']) }

  before { Application.stub('location_service.client', client_double ) }
  after  { Application.unstub('location_service.client') }

  let(:response_data) do
    Dry::Monads::Result::Success.new(
      [
        {
          'latitude'   => 48.864193,
          'longitude'  => 2.350498,
          'updated_at' => '2018-04-05T22:36:16Z'
        },
        {
          'latitude'   => 48.863921,
          'longitude'  =>  2.349211,
          'updated_at' => '2018-04-05T22:36:21Z'
        }
      ]
    )
  end

  it 'constructs correct path and passes params' do
    expect(client_double).to receive(:get).with(
      path: '/drivers/1/locations',
      params: { minutes: 5 }
    ).and_return(response_data)

    recent_locations
  end

  context 'bad id' do
    let(:id) { 'a b' }
    it 'uri escapes bad ids' do
      expect(client_double).to receive(:get).with(
        path: '/drivers/a%20b/locations',
        params: { minutes: 5 }
      ).and_return(response_data)

      recent_locations
    end
  end

  context 'structured data' do
    before do
      allow(client_double).to receive(:get).and_return(response_data)
    end

    it 'correctly wraps data' do
      expect(recent_locations.success?).to eq(true)

      location_data = recent_locations.value!

      expect(location_data.user_id).to eq(id)
      expect(location_data.minutes).to eq(minutes)

      first_location = location_data.locations[0]

      expect(first_location.latitude).to eq(48.864193)
      expect(first_location.longitude).to eq(2.350498)
      expect(first_location.updated_at).to eq(Time.parse('2018-04-05T22:36:16Z'))

      second_location = location_data.locations[1]

      expect(second_location.latitude).to eq(48.863921)
      expect(second_location.longitude).to eq(2.349211)
      expect(second_location.updated_at).to eq(Time.parse('2018-04-05T22:36:21Z'))

    end
  end
end
