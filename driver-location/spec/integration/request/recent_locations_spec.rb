# frozen_string_literal: true

require 'web/app'

RSpec.describe 'RecentLocations' do
  include Rack::Test::Methods

  let(:id) { 1 }
  let(:minutes) { 5 }

  let(:url) { "/drivers/#{id}/locations?minutes=#{minutes}" }

  def app
    Web::App
  end

  before { Application['persistence.drop_db'].call }

  subject(:response) do
    get(url)
    last_response
  end

  context 'invalid params' do
    let(:minutes) { -1 }

    it { expect(response.status).to eq(422) }
    it { expect(response.body).to start_with('{"errors":{"minutes":') }
    it { expect(response.headers.fetch('Content-Type')).to eq('application/json') }
  end

  context 'no data' do
    it { expect(response.status).to eq(200) }
    it { expect(response.body).to eq('[]') }
    it { expect(response.headers.fetch('Content-Type')).to eq('application/json') }
  end

  context 'with data' do
    let(:time) { Time.now.utc }
    let(:events) do
      {
        relevant: Types::LocationEvent.new(
          latitude: 1.0,
          longitude: 2.0,
          user_id: id,
          received_at: time
        ),
        other: Types::LocationEvent.new(
          latitude: 3.0,
          longitude: 4.0,
          user_id: 'other',
          received_at: time + 1,
        )
      }
    end

    before do
      repo = Application['persistence.location_repo']

      events.values.each { |e| repo.record_event(e) }
    end

    it { expect(response.status).to eq(200) }

    it 'returns the correct event' do
      expect(response.body).to eq(
        %([{"latitude":1.0,"longitude":2.0,"updated_at":"#{events[:relevant].received_at.iso8601}"}])
      )
    end
  end

end
