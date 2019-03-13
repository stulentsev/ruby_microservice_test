# frozen_string_literal: true

require 'import'
require 'serverengine'

module Listener
  class Worker
    include Import['messaging.consumer_provider']
    include Import['listener.process_message']

    def initialize(*)
      @stop_flag = ServerEngine::BlockingFlag.new
      super
    end

    def run(topic:, channel:, blocking: false)
      consumer_provider.with_consumer(topic: topic, channel: channel) do |consumer|
        until @stop_flag.set?
          message = pop_message(consumer: consumer, blocking: blocking)
          process_message.call(message) if message
        end
      end
    end

    def stop
      @stop_flag.set!
    end

    private

    def pop_message(consumer:, blocking:, timeout: 0.1)
      return consumer.pop if blocking

      consumer.pop_without_blocking.tap do |msg|
        sleep timeout unless msg
      end
    end
  end
end
