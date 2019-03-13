# frozen_string_literal: true

Dry::System.register_component(:messaging, provider: :common) do
  settings do
    key :logger, Common::Types::Any
    key :use_ephemeral, Common::Types::Strict::Bool.default(false)
    key :nsq_lookupd, Common::Types::Strict::String
    key :pool_size, Common::Types::Strict::Integer.default(5)
  end

  init do
    require 'nsq'
    require 'dry/core/cache'
    require 'connection_pool'
  end

  start do
    Nsq.logger = config.logger

    producer_factory = ::Common::Messaging::ProducerFactory.new(
      nsq_lookupd: config.nsq_lookupd
    )

    register(:producer_pool, cache: true) do
      ConnectionPool.new(size: config.pool_size) { producer_factory.call }
    end

    register(:write_message, ::Common::Messaging::WriteMessage.new)

  end
end
