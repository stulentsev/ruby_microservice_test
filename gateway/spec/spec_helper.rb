# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'pry'
require_relative '../system/container'
require 'dry/system/stubs'
require 'typhoeus'

require 'rack/test'
require 'securerandom'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def stub_request(url:, response:)
    Typhoeus::Expectation.clear
    Typhoeus.stub(url).and_return(response)
  end

  def response_double(*args, **kwargs)
    Typhoeus::Response.new(*args, **kwargs)
  end

  config.before(:suite) do
    Application.enable_stubs!
    Application.finalize!
  end
end
