# frozen_string_literal: true

RSpec.describe 'RackHelpers::ExtractRequestHeaders' do
  let(:extract_request_headers) { Application['rack_helpers.extract_request_headers'] }

  let(:env_hash) do
    {
      'SCRIPT_NAME' => '/drivers/5/locations',
      'QUERY_STRING' => 'minutes=5',
      'SERVER_PROTOCOL' => 'HTTP/1.1',
      'SERVER_SOFTWARE' => 'puma 3.12.0 Llamas in Pajamas',
      'GATEWAY_INTERFACE' => 'CGI/1.2',
      'REQUEST_METHOD' => 'PATCH',
      'REQUEST_PATH' => '/drivers/5/locations',
      'REQUEST_URI' => '/drivers/5/locations?minutes=5',
      'HTTP_VERSION' => 'HTTP/1.1',
      'HTTP_HOST' => 'localhost:3800',
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0',
      'HTTP_ACCEPT' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'HTTP_ACCEPT_LANGUAGE' => 'en-US,en;q=0.5',
      'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
      'HTTP_CONNECTION' => 'keep-alive',
      'HTTP_COOKIE' => 'referrer_url=direct;',
      'HTTP_UPGRADE_INSECURE_REQUESTS' => '1',
      'HTTP_CACHE_CONTROL' => 'max-age=0',
      'CONTENT_TYPE' => 'application/json',
      'CONTENT_LENGTH' => '26',
      'SERVER_NAME' => 'localhost',
      'SERVER_PORT' => '3800',
      'PATH_INFO' => '',
      'REMOTE_ADDR' => '127.0.0.1'
    }
  end

  let(:url) { 'http://localhost:3800/drivers/5/locations' }

  let(:rack_request_env) do
    Rack::MockRequest.env_for(url, env_hash)
  end

  subject(:request_headers) { extract_request_headers.call(rack_env: rack_request_env) }

  it 'extracts and normalizes request headers ' do
    expect(request_headers).to eq(
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate',
      'Accept-Language' => 'en-US,en;q=0.5',
      'Cache-Control' => 'max-age=0',
      'Content-Length' => '26',
      'Content-Type' => 'application/json',
      'Cookie' => 'referrer_url=direct;',
      'Upgrade-Insecure-Requests' => '1',
      'User-Agent' => 'Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0',
      'Version' => 'HTTP/1.1'
    )
  end
end
