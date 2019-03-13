# frozen_string_literal: true

require 'import'

module Listener
  class ProcessMessage
    include Import['listener.record_location']
    include Import[json_parser: 'json.parser']
    include Import['logger']
    include Import['messaging.requeue_timeout']
    include Import['messaging.max_requeues']

    def call(message)
      Dry::Matcher::ResultMatcher.call(
        json_parser.call(message.body)
      ) do |m|
        m.success { |message_body| persist(message_body, message) }
        m.failure { |err| notify_and_finish(err, message) }
      end
    end

    private

    def persist(message_body, message)
      message_body['timestamp'] = message.timestamp

      record_location.call(message_body) do |result|
        result.success { finish(message) }

        result.failure(:validate) { |err| notify_and_finish(err, message) }
        result.failure(:persist)  { |err| notify_and_requeue(err, message) }
      end
    end

    def notify_and_finish(err, message)
      notify(err)
      finish(message)
    end

    def notify_and_requeue(err, message)
      notify(err)
      requeue(message)
    end

    def notify(err)
      logger.error(err)
    end

    def finish(message)
      message.finish
    end

    def requeue(message)
      if message.attempts < max_requeues
        message.requeue(requeue_timeout.call(message.attempts))
      else
        message.finish
      end
    end
  end
end
