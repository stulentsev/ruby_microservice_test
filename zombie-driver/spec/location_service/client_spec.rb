# frozen_string_literal: true

RSpec.describe 'LocationService::Client' do
  let(:client) { Application['location_service.client'] }
  subject(:response) { client.get(path: path, params: params, headers: headers) }

  let(:path) { '/my/path' }
  let(:params) { { key: 'value' } }

  let!(:request_double) { object_double(Application['http_client.request']) }

  before { Application.stub('http_client.request', request_double) }
  after  { Application.unstub('http_client.request') }

  let(:base_url) { 'http://base-url/' }
  before { Application.stub('location_service.url', 'http://base-url/') }
  after  { Application.unstub('location_service.url') }

  let(:json_result) { Dry::Monads::Result::Success.new('{"key":"value"}') }

  let(:headers) { {} }

  it 'constructs a proper request with default headers' do
    expect(request_double).to receive(:call).with(
      headers: { 'Accept' => 'application/json' },
      method: :get,
      params: { key: 'value' },
      url: 'http://base-url/my/path'
    ).and_return(json_result)

    response
  end

  context 'custom headers' do
    let(:headers) { { 'Accept' => '*', 'X-Requested-For' => 'client' } }

    it 'accepts custom headers that override defaults' do
      expect(request_double).to receive(:call).with(
        headers: { 'Accept' => '*', 'X-Requested-For' => 'client' },
        method: :get,
        params: { key: 'value' },
        url: 'http://base-url/my/path'
      ).and_return(json_result)

      response
    end
  end

  describe 'json parsing' do
    before do
      allow(request_double).to receive(:call).and_return(json_result)
    end

    context 'valid json' do
      let(:json_result) { Dry::Monads::Result::Success.new('{"key":"value"}') }

      it 'decodes json' do
        expect(response.value!).to eq('key' => 'value')
      end
    end

    context 'invalid json' do
      let(:json_result) { Dry::Monads::Result::Success.new('{"key"}') }

      it 'returns a failure' do
        expect(response.failure?).to eq(true)
      end
    end

    context 'empty response' do
      let(:json_result) { Dry::Monads::Result::Success.new('') }

      it { expect(response.success?).to eq(true) }
    end

  end
end
