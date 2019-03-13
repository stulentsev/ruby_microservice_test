module RackHelpers
  class TransformHeaders
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

    def call(env:)
      env
        .select  { |key, _| key.start_with?('HTTP_') || CONTENT_HEADERS.include?(key) }
        .reject  { |key, _| IGNORED_HEADERS.include?(key) }
        .collect { |key, value| [key.sub(/^HTTP_/, '').tr('_', '-'), value] }
    end
  end
end
