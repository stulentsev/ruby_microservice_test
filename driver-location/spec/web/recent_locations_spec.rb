# frozen_string_literal: true

RSpec.describe 'Web::RecentLocations' do
  let(:described_class) { Application['web.recent_locations'] }
  let(:recent_locations) { described_class.call(params) }

  let(:location_repo_double) { instance_double(Persistence::LocationRepo) }

  let(:time) { Time.parse('2018-04-05 22:36:21 UTC') }

  before do
    Application.stub('persistence.location_repo', location_repo_double)
  end

  after do
    Application.unstub('persistence.location_repo')
  end

  describe 'result format' do
    let(:params) { { 'user_id' => 1, 'minutes' => 2 } }
    let(:records) {
      [
        Types::LocationUpdate.new(
          latitude: 1.0,
          longitude: 2.0,
          updated_at: time
        ),
        Types::LocationUpdate.new(
          latitude: 3.0,
          longitude: 4.0,
          updated_at: time + 1
        )
      ]
    }

    it 'returns correctly formatted events' do
      expect(location_repo_double).to receive(:recent_locations_for_user).with(
        user_id: 1, seconds: 120
      ).and_return(records)

      expect(recent_locations.value!).to eq(
        [
          {
            latitude: 1.0,
            longitude: 2.0,
            updated_at: '2018-04-05T22:36:21Z'
          },
          {
            latitude: 3.0,
            longitude: 4.0,
            updated_at: '2018-04-05T22:36:22Z'
          }
        ]
      )
    end
  end

  context 'string user' do
    let(:params) { { 'user_id' => SecureRandom.uuid.to_s, 'minutes' => 2 } }
    it 'works string ids' do
      expect(location_repo_double).to receive(:recent_locations_for_user).and_return([])

      recent_locations.value!
    end
  end

  describe 'validation' do
    let(:errors) { recent_locations.failure.keys }

    context 'missing minutes' do
      let(:params) { { 'user_id' => 1 } }

      it { expect(errors).to eq([:minutes]) }
    end

    context 'empty minutes' do
      let(:params) { { 'user_id' => 1, 'minutes' => '' } }

      it { expect(errors).to eq([:minutes]) }
    end

    context 'invalid minutes type' do
      let(:params) { { 'user_id' => 1, 'minutes' => 'asd' } }

      it { expect(errors).to eq([:minutes]) }
    end

    context 'negative minutes value' do
      let(:params) { { 'user_id' => 1, 'minutes' => -5 } }

      it { expect(errors).to eq([:minutes]) }
    end

    context 'huge minutes value' do
      let(:params) { { 'user_id' => 1, 'minutes' => 5_000_000_000_000 } }

      it { expect(errors).to eq([:minutes]) }
    end

    context 'missing user' do
      let(:params) { { 'minutes' => 1 } }

      it { expect(errors).to eq([:user_id]) }
    end

    context 'empty user' do
      let(:params) { { 'minutes' => 1, 'user_id' => '' } }

      it { expect(errors).to eq([:user_id]) }
    end

    context 'invalid user type' do
      let(:params) { { 'minutes' => 1, 'user_id' => {} } }

      it { expect(errors).to eq([:user_id]) }
    end

  end
end
