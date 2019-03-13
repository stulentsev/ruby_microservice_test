# frozen_string_literal: true

require 'typhoeus'

RSpec.describe 'HttpClient::Request' do
  let(:request) { Application['http_client.request'] }

  let(:url) { 'http://example.local' }
  let(:response_body) { 'body' }

  let(:stubbed_url) { url }

  before do
    stub_request(url: stubbed_url, response: response)
  end

  context 'success' do
    let(:response) { response_double(code: 200, body: response_body) }

    it { expect(request.call(url: url).success?).to eq(true) }
    it { expect(request.call(url: url).value!).to eq(response_body) }
  end

  context 'time out' do
    let(:response) { response_double(return_code: :operation_timedout) }

    it { expect(request.call(url: url).failure).to be_a(Application['http_client.errors.timeout_error']) }
  end

  context 'network error' do
    let(:response) { response_double(code: 0) }

    it { expect(request.call(url: url).failure).to be_a(Application['http_client.errors.network_error']) }
  end

  context 'client error' do
    let(:response) { response_double(code: 404) }

    it { expect(request.call(url: url).failure).to be_a(Application['http_client.errors.client_error']) }
  end

  context 'server error' do
    let(:response) { response_double(code: 503) }

    it { expect(request.call(url: url).failure).to be_a(Application['http_client.errors.server_error']) }
  end
end
