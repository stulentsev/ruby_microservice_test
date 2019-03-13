# frozen_string_literal: true

require 'import'
require 'types'

module ConfigurationLoader
  class Yaml
    include Dry::Monads::Result::Mixin
    include Import[yaml_parser: 'yaml.parser']

    Schema = Dry::Validation.Params do
      required(:urls).each do
        schema do
          required(:path).filled(:str?)
          required(:method).filled

          optional(:http).schema do
            required(:host).filled(:str?)
          end

          optional(:nsq).schema do
            required(:topic).filled(:str?)
          end

          rule(exactly_one_forward: %i[http nsq]) do |*forwards|
            # XOR - EXACTLY ONE of the forwards must be filled
            forwards.map(&:filled?).reduce(:^)
          end

          rule(supported_http_method: %i[method http]) do |verb, http|
            http.filled? > verb.included_in?(::Types::HttpSupportedVerb.values)
          end

          rule(supported_nsq_method: %i[method nsq]) do |verb, nsq|
            nsq.filled? > verb.included_in?(::Types::NsqSupportedVerb.values)
          end
        end
      end
    end

    def call(input)
      return Failure('Missing YAML string') unless input
      return Failure('Empty YAML string') if input.strip == ''

      yaml_parser.call(input).bind do |parsed_config|
        Schema.call(parsed_config).to_monad.bind do |valid_config_hash|
          Success(build_config_struct(valid_config_hash))
        end
      end
    end

    private

    def build_config_struct(valid_config_hash)
      ::Types::RoutingConfigList[
        valid_config_hash.fetch(:urls).map do |url_config|
          rename_method_to_verb(url_config)
        end
      ]
    end

    def rename_method_to_verb(url_config)
      verb = url_config.delete(:method)
      url_config[:verb] = verb
      url_config
    end

  end
end
