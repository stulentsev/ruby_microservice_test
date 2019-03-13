# frozen_string_literal: true

RSpec.describe 'RackHelpers::GenerateProxyHeaders' do
  let(:generate_headers) { Application['rack_helpers.generate_proxy_headers'] }

  let(:url) { 'http://localhost:3800/drivers/5/locations' }

  let(:rack_request_env) do
    Rack::MockRequest.env_for(url, env_hash)
  end

  subject(:result) { generate_headers.call(rack_env: rack_request_env) }

  context 'existing forward headers' do
    let(:env_hash) do
      {
        'HTTP_X_FORWARDED_FOR' => '203.0.113.195, 70.41.3.18',
        'REMOTE_ADDR' => '127.0.0.1'
      }
    end

    it 'appends the curren remote addr' do
      expect(result).to eq('X-Forwarded-For' => '203.0.113.195, 70.41.3.18, 127.0.0.1')
    end
  end

  context 'no previous forward' do
    let(:env_hash) do
      {
        'REMOTE_ADDR' => '127.0.0.1'
      }
    end

    it 'creates a new entry with the remote addr' do
      expect(result).to eq('X-Forwarded-For' => '127.0.0.1')
    end
  end

  context 'no remote addr info' do
    let(:env_hash) { {} }

    it 'doesnt include forwarding info' do
      expect(result).not_to have_key('X-Forwarded-For')
    end
  end

end
