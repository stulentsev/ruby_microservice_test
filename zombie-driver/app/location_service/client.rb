# frozen_string_literal: true

module LocationService
  class Client
    include Dry::Monads::Result::Mixin

    include Import['http_client.request']
    include Import[base_url: 'location_service.url']
    include Import[json_parser: 'json.parser']

    DEFAULT_HEADERS = { Accept: 'application/json' }.freeze

    def get(path:, params: {}, headers: {})
      request.call(
        url: url(path),
        method: :get,
        params: params,
        # override defaults
        headers: default_headers.merge(headers)
      ).bind do |response_body|
        return Success() if !response_body || response_body.empty?

        json_parser.call(response_body)
      end
    end

    private

    def url(path)
      URI.join(base_url, path).to_s
    end

    def default_headers
      { 'Accept' => 'application/json' }
    end
  end
end
