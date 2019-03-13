# frozen_string_literal: true

module RackHelpers
  class GenerateProxyHeaders

    X_FORWARDED_FOR      = 'X-Forwarded-For'
    X_FORWARDED_FOR_RACK = 'HTTP_X_FORWARDED_FOR'

    REMOTE_ADDR_RACK     = 'REMOTE_ADDR'

    def call(rack_env:)
      result = {}
      # only set forwarded header if we have the remote addr
      result['X-Forwarded-For'] = x_forwarded_for(rack_env) if rack_env[REMOTE_ADDR_RACK]

      result
    end

    private

    def x_forwarded_for(env)
      # unpack current X-Forwarded-For; it's a comma separated list
      forwarded_for = env[X_FORWARDED_FOR_RACK].to_s.split(/, +/) if env[X_FORWARDED_FOR_RACK]

      # get our current request addr
      request_remote_addr = env[REMOTE_ADDR_RACK]

      # merge the prev forwards with the current one
      # and generate proper comma separated format
      [forwarded_for, request_remote_addr].compact.join(', ')
    end
  end
end
