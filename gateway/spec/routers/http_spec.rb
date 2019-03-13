# frozen_string_literal: true

RSpec.shared_examples 'Routers::Http::Shared' do |method|
  let(:router) { Application['routers.http'] }

  let(:path) { '/drivers/5?minutes=5' }
  let(:body) { 'body' }
  let(:destination_host) { 'zombie-service' }
  let(:headers) { { 'Accept' => 'application/json' } }

  let(:upstream_headers) { { 'Content-Type' => 'application/json' } }
  let(:upstream_response_body) { 'body' }


  subject(:response) {
    router.call(
      path: path,
      method: method,
      headers: headers,
      body: body,
      destination_host: destination_host
    )
  }

  let(:stubbed_url) { 'http://zombie-service/drivers/5?minutes=5' }

  before do
    stub_request(url: stubbed_url, response: upstream_response)
  end

  context 'success' do
    let(:upstream_response) { response_double(code: 200, body: upstream_response_body, headers: upstream_headers) }

    it { expect(response.status).to eq(200) }
    it { expect(response.headers).to eq(upstream_headers) }
    it { expect(response.body).to eq(upstream_response_body) }
  end

  context 'error' do
    let(:upstream_response) { response_double(code: 422, body: upstream_response_body, headers: upstream_headers) }

    it { expect(response.status).to eq(422) }
    it { expect(response.headers).to eq(upstream_headers) }
    it { expect(response.body).to eq(upstream_response_body) }
  end

  context 'time out' do
    let(:upstream_response) { response_double(return_code: :operation_timedout) }

    it { expect(response.status).to eq(504) }
    it { expect(response.headers).to eq({}) }
    it { expect(response.body).to eq(nil) }
  end

  context 'network error' do
    let(:upstream_response) { response_double(code: 0) }

    it { expect(response.status).to eq(502) }
    it { expect(response.headers).to eq({}) }
    it { expect(response.body).to eq(nil) }
  end
end

RSpec.describe 'Routers::Http' do
  include_examples 'Routers::Http::Shared', :get
end
