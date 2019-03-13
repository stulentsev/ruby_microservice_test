# frozen_string_literal: true

Dry::System.register_component(:messaging, provider: :common) do
  settings do
    key :logger, Common::Types::Any
    key :default_channel, Common::Types::Strict::String
    key :default_topic, Common::Types::Strict::String
    key :use_ephemeral, Common::Types::Strict::Bool.default(false)
    key :nsq_lookupd, Common::Types::Strict::String
  end

  init do
    require 'nsq'
  end

  start do
    Nsq.logger = config.logger

    # timeout in miliseconds to reque the message to the exchange if we
    # can't persist it
    register(:requeue_timeout) do |attempts|
      1_000 * attempts
    end

    register(:max_requeues) { 5 }

    register(:consumer_factory) do |host: nil, topic:, channel:|
      h = host || config.nsq_lookupd
      t = topic || condif.default_topic

      # allow custom channel name, but prefer to conect to a static channel
      # based on the app name
      c = channel || config.default_channel

      # in test env we create random topics and channels the magic `#ephemeral`
      # modifier in the end of the names means that the topic and channel won't
      # persist messages and will be deleted after the last client disconnects
      # from them
      t = "#{t}#ephemeral" if t && config.use_ephemeral
      c = "#{c}#ephemeral" if c && config.use_ephemeral

      Nsq::Consumer.new(
        nsqlookupd: h,
        topic: t,
        channel: c
      )
    end

    register(:write_message, ::Common::Messaging::WriteMessage.new)
    register(:producer_factory, ::Common::Messaging::ProducerFactory.new(nsq_lookupd: config.nsq_lookupd))
  end
end
