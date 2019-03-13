# frozen_string_literal: true

require 'request_handlers/http_forward'
require 'http_router'

RSpec.describe RequestHandlers::HTTPForward do
  include Rack::Test::Methods

  let(:destination_host) { 'driver-location' }

  subject(:http_forward) {
    described_class.new(
      destination_host: destination_host,
      http_router: http_router
    )
  }

  let(:logger_double) { object_double(Application['logger']).as_null_object }
  let(:http_router) { object_double(Application['routers.http']) }

  def app
    router = HttpRouter.new
    router.add('/drivers/:id/locations', method: 'GET').to(http_forward)

    builder = Rack::Builder.new
    builder.run(router)
  end

  let(:headers) { { 'Accept' => 'application/json' } }

  let(:proxy_response) {
    Types::ProxyResponse.new(status: 200, body: '', headers: {})
  }

  describe 'GET' do
    let(:request_path) { '/drivers/5/locations' }

    it 'correctly forwards to the router' do
      expect(http_router).to receive(:call).with(
        path: request_path,
        method: :get,
        destination_host: destination_host,
        headers: {
          'Content-Length' => '0',
          'Cookie' => '',
          'X-Forwarded-For' => '127.0.0.1'
        },
        body: ''
      ).and_return(proxy_response)

      get request_path
    end
  end

  describe 'GET with query string' do
    let(:request_path) { '/drivers/5/locations?minutes=5&hours=5' }

    it 'correctly forwards to the router' do
      expect(http_router).to receive(:call).with(
        path: request_path,
        method: :get,
        destination_host: destination_host,
        headers: {
          'Content-Length' => '0',
          'Cookie' => '',
          'X-Forwarded-For' => '127.0.0.1'
        },
        body: ''
      ).and_return(proxy_response)

      get request_path
    end
  end

  describe 'POST' do
    let(:request_path) { '/drivers/5/locations?minutes=5' }

    it 'correctly forwards to the router' do
      expect(http_router).to receive(:call).with(
        path: request_path,
        method: :post,
        destination_host: destination_host,
        headers: {
          'Content-Length' => '4',
          'Cookie' => '',
          'X-Forwarded-For' => '127.0.0.1',
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        body: 'body'
      ).and_return(proxy_response)

      post request_path, 'body'
    end
  end
end
