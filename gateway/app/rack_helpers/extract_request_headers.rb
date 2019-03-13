# frozen_string_literal: true

module RackHelpers
  class ExtractRequestHeaders

    # HTTP header prefix from Rack
    RACK_PREFIX = 'HTTP_'

    # Content-Type and Content-Length are not prefixed with HTTP in the env
    CONTENT_HEADERS = %w[
      CONTENT_LENGTH
      CONTENT_TYPE
    ].freeze

    # Ignore rack internal headers
    IGNORED_HEADERS = %w[
      HTTP_HOST
      HTTP_CONNECTION
    ].freeze

    def call(rack_env:)
      Hash[
        rack_env
        .select  { |key, _| key.start_with?(RACK_PREFIX) || CONTENT_HEADERS.include?(key) }
        .reject  { |key, _| IGNORED_HEADERS.include?(key) }
        .map { |key, value| [normalize_header_name(key), value] }
      ]
    end

    private

    # Transforms rack headers to "standard" headers
    #
    # HTTP_ACCEPT_LANGUAGE -> Accept-Language
    def normalize_header_name(name)
      name.
        # remove heading HTTP if present
        sub(/^#{RACK_PREFIX}/, '').
        # split on underscore
        split('_').
        # transform UPCASE to Upcase
        map(&:capitalize).
        # join back on a dash
        join('-')
    end

  end
end
