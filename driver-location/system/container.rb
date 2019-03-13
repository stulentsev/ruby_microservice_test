# frozen_string_literal: true

require 'dry/system/container'
require 'dry/transaction'
require 'dry/validation'
require 'dry/matcher/result_matcher'

require_relative '../lib/common/components'

class Application < Dry::System::Container
  setting :name, :driver_location
  setting :env, (ENV['RACK_ENV'] || 'development')

  configure do |config|
    config.auto_register = %w[app]
  end

  Dry::Validation.load_extensions(:monads)

  boot(:logger, from: :common)
  boot(:json, from: :common, namespace: :json)

  boot(:messaging, from: :common, namespace: :messaging) do
    configure do |config|
      config.logger = Application[:logger]
      config.default_channel = ENV.fetch('NSQ_CHANNEL', Application.config.name.to_s)
      config.default_topic = ENV.fetch('NSQ_TOPIC', 'locations')
      config.use_ephemeral = Application.config.env == 'test'
      config.nsq_lookupd = ENV.fetch('NSQ_LOOKUPD', '127.0.0.1:4161')
    end
  end

  load_paths!('app')
end
