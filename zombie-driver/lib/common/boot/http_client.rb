# frozen_string_literal: true

require_relative '../http_client'

Dry::System.register_component(:http_client, provider: :common) do
  init do
    require 'typhoeus'
  end

  start do
    register(:url_encoder, call: false) do |input|
      URI.encode(input.to_s)
    end

    register(:request) { Common::HTTPClient::Request.new }
    register('errors.timeout_error', call: false) { Common::HTTPClient::Errors::TimeoutError }
    register('errors.network_error', call: false) { Common::HTTPClient::Errors::NetworkError }
    register('errors.client_error', call: false) { Common::HTTPClient::Errors::ClientError }
    register('errors.server_error', call: false) { Common::HTTPClient::Errors::ServerError }
  end
end
