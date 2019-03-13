# frozen_string_literal: true

require 'import'

module Messaging
  class ConsumerProvider
    include Import['messaging.consumer_factory']

    def with_consumer(topic: nil, channel: nil)
      consumer = consumer_factory.call(topic: topic, channel: channel)
      yield(consumer)
    ensure
      consumer&.terminate
    end
  end
end
