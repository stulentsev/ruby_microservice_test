module Common
  module Messaging
    class WriteMessage
      include Dry::Monads::Result::Mixin

      # Safe write a message
      #
      # When we get a connection to nsqlookupd it may not initially find an
      # nsqd instance from nsqlookupd.
      #
      # It may take a second or two. So we need to retry. It's not exponential,
      # as we expect the connection to be shortly available. And even if it's
      # we want to fail as fast as possible and let clients retry themselves
      # with appropriate timeouts
      def call(producer:, topic:, message:, max_retries: 5, retry_timeout: 0.1)
        retries = 0
        begin
          producer.write_to_topic(topic, message)
          Success()
        # something is wrong with the cluster - just error out without retries
        rescue Errno::ECONNREFUSED => e
          Failure(e)
        # no connections available raises this descriptive error :(
        rescue RuntimeError => e
          retries += 1

          if retries < max_retries
            sleep(retry_timeout)
            retry
          end

          Failure(e)
        end
      end

    end
  end
end
