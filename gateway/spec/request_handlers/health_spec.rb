# frozen_string_literal: true

RSpec.describe 'RequestHandlers::Health' do
  include Rack::Test::Methods

  def app
    builder = Rack::Builder.new
    builder.run(Application['request_handlers.health'])
  end

  before { get '/' }

  it 'returns the app status' do
    expect(last_response.body).to eq('{"status":"ok","app_name":"gateway"}')
    expect(last_response.status).to eq(200)
    expect(last_response.headers.fetch('Content-Type')).to eq('application/json')
  end
end
