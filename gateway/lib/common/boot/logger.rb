# frozen_string_literal: true

Dry::System.register_component(:logger, provider: :common) do
  settings do
    key :logger, Common::Types::Any.default(Logger.new($stdout))
  end

  init do
    require 'logger'
  end

  start do
    register(:logger, config.logger)
  end
end
