# frozen_string_literal: true

require 'request_handlers/nsq_forward'
require 'http_router'

RSpec.describe RequestHandlers::NsqForward do
  include Rack::Test::Methods

  let(:topic) { 'locations' }
  let(:nsq_router) { object_double(Application['routers.nsq']) }

  subject(:nsq_forward) {
    described_class.new(topic: topic, nsq_router: nsq_router) 
  }

  def app
    router = HttpRouter.new
    router.add('/drivers/:id/locations', method: 'POST').to(nsq_forward)
    router.add('/drivers/locations', method: 'POST').to(nsq_forward)

    builder = Rack::Builder.new
    builder.run(router)
  end

  let(:headers) { { 'Accept' => 'application/json' } }

  let(:proxy_response) {
    Types::ProxyResponse.new(status: 200, body: '', headers: {})
  }

  context 'with path params' do
    let(:url) { '/drivers/5/locations' }

    it 'correctly forwards to the nsq handler' do
      expect(nsq_router).to receive(:call).with(
        params: { id: '5' },
        body: 'body',
        topic: topic
      ).and_return(proxy_response)

      post url, 'body'
    end
  end

  context 'without path params' do
    let(:url) { '/drivers/locations' }

    it 'correctly forwards to the nsq handler' do
      expect(nsq_router).to receive(:call).with(
        params: {},
        body: 'body',
        topic: topic
      ).and_return(proxy_response)

      post url, 'body'
    end
  end
end
