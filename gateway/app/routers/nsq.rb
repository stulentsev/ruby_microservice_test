# frozen_string_literal: true

require 'import'

module Routers
  class Nsq
    include Dry::Monads::Result::Mixin
    include Import['messaging.producer_pool']
    include Import['messaging.write_message']
    include Import[json_parser: 'json.parser']
    include Import[json_encoder: 'json.generator']

    BAD_REQUEST = 400
    NO_CONTENT = 204

    def call(params:, body:, topic:)
      check_for_body_and_params(params: params, body: body).bind do
        maybe_parse_body_json(body: body).bind do |parsed_body|
          # prioritize params from the URL to parms from the body
          message_body = parsed_body.merge(params.transform_keys(&:to_s))

          publish_message(message: message_body, topic: topic).bind do
            Success(no_content)
          end

        end
      end.value_or { |e| bad_request(e.to_s) }
    end

    private

    def check_for_body_and_params(params:, body:)
      if params.empty? && (!body || body.empty?)
        Failure('No parameters or request body')
      else
        Success()
      end
    end

    def maybe_parse_body_json(body:)
      return Success({}) if !body || body.empty?

      json_parser.call(body)
    end

    def publish_message(message:, topic:)
      json_message = json_encoder.call(message).value!

      producer_pool.with do |producer|
        write_message.call(producer: producer, topic: topic, message: json_message)
      end
    end

    def bad_request(body)
      ::Types::ProxyResponse.new(
        status: BAD_REQUEST,
        headers: { 'Content-type' => 'text/plain; charset=us-ascii' },
        body: body.to_s
      )
    end

    def no_content
      ::Types::ProxyResponse.new(
        status: NO_CONTENT,
        headers: {},
        body: nil
      )
    end

  end
end
