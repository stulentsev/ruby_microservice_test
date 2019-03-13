# frozen_string_literal: true

Dry::System.register_component(:yaml, provider: :common) do
  init do
    require 'dry/monads/result'

    require 'yaml'
  end

  start do
    register(:parser) do |string|
      Dry::Monads::Result::Success.new(YAML.safe_load(string))
    rescue Psych::SyntaxError => e
      Dry::Monads::Result::Failure.new(e)
    end
  end
end
