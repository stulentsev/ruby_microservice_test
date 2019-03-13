# frozen_string_literal: true

require 'dry/system/container'
require 'dry/transaction'
require 'dry/validation'
require 'dry/matcher/result_matcher'
require 'dry/monads/maybe'

require_relative '../lib/common/components'

class Application < Dry::System::Container
  setting :name, :gateway
  setting :env, (ENV['RACK_ENV'] || 'development')

  configure do |config|
    config.auto_register = %w[app]
  end

  Dry::Validation.load_extensions(:monads)
  Dry::Validation.load_extensions(:struct)

  boot(:logger, from: :common)
  boot(:json, from: :common, namespace: :json)
  boot(:yaml, from: :common, namespace: :yaml)

  boot(:messaging, from: :common, namespace: :messaging) do
    configure do |config|
      config.logger = Application[:logger]
      config.use_ephemeral = Application.config.env == 'test'
      config.nsq_lookupd = ENV.fetch('NSQ_LOOKUPD', '127.0.0.1:4161')
    end
  end

  load_paths!('app')
end
