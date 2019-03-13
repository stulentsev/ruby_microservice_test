RSpec.describe 'ZombieStatus' do
  let(:service) { Application['web.zombie_status'] }
  subject(:result) { service.call(params) }

  let(:user_id) { 1 }
  let(:params) { { id: user_id } }

  let(:period_in_minutes) { 5 }

  let(:recent_locations) {
    Dry::Monads.Success(
      Types::RecentLocations.new(
        locations: [],
        user_id: 1,
        minutes: period_in_minutes
      )
    )
  }

  let(:recent_locations_double) do
    object_double(
      Application['location_service.recent_locations'],
      call: recent_locations
    )
  end

  let(:zombie_status) { Dry::Monads.Success(true) }

  let(:zombie_status_double) do
    object_double(Application['zombie.status'], call: zombie_status)
  end

  before do
    Application.stub('location_service.recent_locations', recent_locations_double)
    Application.stub('zombie.constants.period_in_minutes', period_in_minutes)
    Application.stub('zombie.status', zombie_status_double)
  end

  after do
    Application.unstub('location_service.recent_locations')
    Application.unstub('zombie.constants.period_in_minutes')
    Application.unstub('zombie.status')
  end

  describe 'success' do

    it 'returns the zombie status and the minutes' do
      expect(result.value!).to eq(minutes: period_in_minutes, zombie: true)
    end
  end

  describe 'validation' do
    let(:user_id) { [] }

    it 'returns validation errors' do
      expect(result.failure.keys).to eq([:id])
    end
  end

  describe 'location fetch errors' do

    let(:recent_locations) { Dry::Monads.Failure() }

    it 'wraps the error' do
      expect(result.failure).to eq(:remote_service_error)
    end
  end

  describe 'zombie status errors' do
    let(:zombie_status) { Dry::Monads.Failure() }

    let(:recent_locations) do
      Dry::Monads.Success(
        Types::RecentLocations.new(
          locations: [],
          user_id: user_id,
          minutes: period_in_minutes
        )
      )
    end

    it 'wraps the error' do
      expect(result.failure).to eq(:not_enough_locations_error)
    end

  end
end
