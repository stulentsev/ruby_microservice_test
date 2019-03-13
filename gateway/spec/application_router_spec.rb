RSpec.describe 'ApplicationRouter' do
  include Rack::Test::Methods
  let(:config) do
    <<~CONFIG_YAML
      urls:
        -
          path: "/resource/:id"
          method: "PATCH"
          nsq:
            topic: "nsq_topic#ephemeral"
        -
          path: "/resource/:id"
          method: "GET"
          http:
            host: "remote-host"
    CONFIG_YAML
  end

  before { Application.stub('configuration.default', config) }
  after { Application.unstub('configuration.default') }

  let(:logger) { object_double(Application[:logger]).as_null_object }
  before { Application.stub(:logger, logger) }
  after { Application.unstub(:logger) }

  def app
    builder = Rack::Builder.new
    builder.run(Application['router.application'])
  end

  describe 'GET /health' do
    let(:path) { '/health' }
    before { get(path) }

    it 'mounts health by default' do
      expect(last_response.status).to eq(200)
    end
  end

  describe 'NSQ routing' do
    let(:path) { '/resource/5' }

    it 'publishes a message' do
      patch(path)

      expect(last_response.status).to eq(204)
    end
  end

  describe 'HTTP routing' do
    let(:response) { response_double(code: 203) }
    let(:path) { '/resource/5' }

    before do
      stub_request(url: "http://remote-host#{path}", response: response)
    end

    it 'forwards the request' do
      get(path)
      expect(last_response.status).to eq(203)
    end
  end
end
