# frozen_string_literal: true

require 'import'

module Constants
  class EnvStore
    include Import['system_env']

    def fetch(key)
      system_env[transform_key(key)]
    end

    private

    def transform_key(key)
      "#{Application.config.name.to_s.upcase}_#{key.upcase}"
    end
  end
end
