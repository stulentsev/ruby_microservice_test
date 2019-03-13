RSpec.describe 'Web base' do
  include Rack::Test::Methods

  def app
    Web::App
  end

  subject(:response) do
    get(url)
    last_response
  end

  describe 'not found' do
    let(:url) { '/whatever' }

    it { expect(response.status).to eq(404) }
  end

  describe '/health' do
    let(:url) { '/health' }

    it { expect(response.status).to eq(200) }
    it { expect(response.body).to eq('{"status":"ok","app_name":"zombie_driver"}') }
    it { expect(response.headers['Content-Type']).to eq('application/json') }
  end
end
