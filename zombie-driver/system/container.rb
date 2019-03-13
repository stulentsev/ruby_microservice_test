# frozen_string_literal: true

require 'dry/system/container'
require 'dry/monads/maybe'
require 'dry-validation'
require 'dry/transaction'

require_relative '../lib/common/components'

class Application < Dry::System::Container
  setting :name, :zombie_driver
  setting :env, (ENV['RACK_ENV'] || 'development')

  configure do |config|
    config.auto_register = %w[app]
  end

  Dry::Validation.load_extensions(:monads)

  boot(:json, from: :common)
  boot(:logger, from: :common)
  boot(:http_client, from: :common, namespace: :http_client)

  load_paths!('app')
end
