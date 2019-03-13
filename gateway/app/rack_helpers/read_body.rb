# frozen_string_literal: true

module RackHelpers
  class ReadBody
    RACK_INPUT = 'rack.input'

    def call(env)
      env.fetch(RACK_INPUT).read
    ensure
      # rewind the StringIO for the body so that we don't break other rack
      # middlewares
      env[RACK_INPUT]&.rewind
    end
  end
end
