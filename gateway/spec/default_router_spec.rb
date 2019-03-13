RSpec.describe 'DefaultRouter' do
  include Rack::Test::Methods
  let(:router) { Application[:router] }

  def app
    builder = Rack::Builder.new
    builder.run(router)
  end

  describe '404' do
    let(:url) { '/whatever' }
    before { get(url) }

    it 'returns not found' do
      expect(last_response.status).to eq(404)
    end
  end

  describe 'GET /health' do
    let(:url) { '/health' }
    before { get(url) }

    it 'mounts health by default' do
      expect(last_response.status).to eq(200)
    end
  end
end
