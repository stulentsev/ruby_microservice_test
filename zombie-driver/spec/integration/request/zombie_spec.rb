RSpec.describe 'Zombie API' do
  include Rack::Test::Methods

  def app
    Web::App
  end

  let(:id) { 1 }
  let(:url) { "/drivers/#{id}" }

  subject(:response) do
    get(url)
    last_response
  end

  let(:location_service_response) { response_double(body: '') }

  let(:stubbed_url) do
    "#{Application['location_service.url']}/drivers/#{id}/locations"
  end

  before do
    stub_request(url: stubbed_url, response: location_service_response)
  end

  context 'is zombie' do
    let(:location_service_response) {
      response_double(code: 200, body: '
        [
          {
            "latitude": 48.864193,
            "longitude": 2.350498,
            "updated_at": "2018-04-05T22:36:16Z"
          },
          {
            "latitude": 48.863921,
            "longitude":  2.349211,
            "updated_at": "2018-04-05T22:36:21Z"
          }
        ]'
      )
    }

    it { expect(response.body).to eq('{"zombie":true,"minutes":5}') }
    it { expect(response.status).to eq(200) }
  end

  context 'is not zombie' do
    let(:location_service_response) {
      response_double(code: 200, body: '
        [
          {
            "latitude": 48.864193,
            "longitude": 2.350498,
            "updated_at": "2018-04-05T22:36:16Z"
          },
          {
            "latitude": 50.000000,
            "longitude":  2.349211,
            "updated_at": "2018-04-05T22:36:21Z"
          }
        ]'
      )
    }

    it { expect(response.body).to eq('{"zombie":false,"minutes":5}') }
    it { expect(response.status).to eq(200) }
  end

  context 'remote service error' do
    let(:location_service_response) { response_double(code: 500) }

    it { expect(response.status).to eq(503) }
    it { expect(response.body).to eq('') }
  end

  context 'not enough data from remote service' do
    let(:location_service_response) { response_double(code: 200, body: '[]') }

    it { expect(response.status).to eq(422) }
    it { expect(response.body).to start_with('{"errors":') }
  end

end
