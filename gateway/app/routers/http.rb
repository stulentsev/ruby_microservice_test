# frozen_string_literal: true

require 'import'
require 'addressable/uri'
require 'typhoeus'

module Routers
  class HTTP
    include Import['logger']

    GATEWAY_TIMEOUT = 504
    BAD_GATEWAY = 502
    DEFAULT_SCHEME = 'http'.freeze

    def call(path:, method:, headers:, body:, destination_host:)
      request = Typhoeus::Request.new(
        build_uri(destination_host, path),
        headers: headers,
        body: body,
        method: method,
        # verbose log of request if debug logger is enabled
        verbose: logger.debug?
      )

      result = Dry::Monads::None()

      request.on_complete do |response|
        result = if response.timed_out?
                   gateway_timeout_response
                 elsif response.code.zero?
                   bad_gateway_response
                 else
                   upstream_response(response)
                 end
      end

      request.run

      result
    end

    private

    def gateway_timeout_response
      ::Types::ProxyResponse.new(
        status: GATEWAY_TIMEOUT,
        headers: {},
        body: nil
      )
    end

    def bad_gateway_response
      ::Types::ProxyResponse.new(
        status: BAD_GATEWAY,
        headers: {},
        body: nil
      )
    end

    def upstream_response(response)
      ::Types::ProxyResponse.new(
        status: response.code,
        headers: response.headers || {},
        body: response.body
      )
    end

    def build_uri(destination_host, path)
      uri = Addressable::URI.new
      uri.host = destination_host
      uri.path = path

      # TODO fix hardcoded scheme
      uri.scheme ||= DEFAULT_SCHEME

      uri.to_s
    end
  end
end
