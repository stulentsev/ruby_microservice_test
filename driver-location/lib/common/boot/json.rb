Dry::System.register_component(:json, provider: :common) do
  init do
    require 'dry/monads/result'

    require 'multi_json'
    MultiJson.use :oj
  end

  start do
    register(:parser) do |string|
      Dry::Monads::Result::Success.new(MultiJson.load(string))
    rescue MultiJson::ParseError => e
      Dry::Monads::Result::Failure.new(e)
    end

    register(:generator) do |object|
      Dry::Monads::Result::Success.new(MultiJson.dump(object))
    end
  end
end
