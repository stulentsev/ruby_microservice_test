# frozen_string_literal: true

module Common
  module HTTPClient
    class Request
      include Dry::Monads::Result::Mixin

      def call(url:, method: :get, headers: {}, params:{}, body: nil)
        request = Typhoeus::Request.new(
          url,
          headers: headers,
          params: params,
          body: body,
          method: method
        )

        # init variable outside the block so that it's part of the block's
        # local scope
        result = Dry::Monads::None()

        request.on_complete do |response|
          if response.success?
            result = Success(response.body)
            # cool
          elsif response.timed_out?
            result = Failure(Errors::TimeoutError.new('Request Timeout'))
          elsif response.code.zero?
            result = Failure(Errors::NetworkError.new(response.return_message))
          elsif response.code && response.code >= 400 && response.code < 500
            result = Failure(Errors::ClientError.new("HTTP status #{response.code}: #{response.body.to_s}"))
          else
            result = Failure(Errors::ServerError.new("HTTP status #{response.code}: #{response.body.to_s}"))
          end
        end

        request.run

        result
      end
    end
  end
end
