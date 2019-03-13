module Common
  module Messaging
    class ProducerFactory
      attr_reader :nsq_lookupd

      def initialize(nsq_lookupd:)
        @nsq_lookupd = nsq_lookupd
      end

      def call
        Nsq::Producer.new(nsqlookupd: nsq_lookupd)
      end

    end
  end
end
