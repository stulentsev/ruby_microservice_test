# frozen_string_literal: true

module Types
  include Dry::Types.module

  Null = ::Class.new

  # CONNECT is not allowed as we don't currently support tunneling or HTTPS
  # TRACE   is not allowed
  # LINK    is not allowed, as it's not supported by Typhoeus.. or is it?
  # UNLINK  is not allowed, as it's not supported by Typhoeus.. or is it?
  #
  # DELETE  is allowed for both http and nsq, nsq messagage body is merged url and request params
  # POST    is allowed for both http and nsq, nsq messagage body is merged url and request params
  # PUT     is allowed for both http and nsq, nsq messagage body is merged url and request params
  # PATCH   is allowed for both http and nsq, nsq messagage body is merged url and request params
  # GET     is allowed only for http, as the nsq is "push only" and can't return data
  # HEAD    is allowed only for http, as nsq is "push only" and has no headers
  # OPTIONS is allowed only for http, as the nsq is "push only" and can't return data
  HttpSupportedVerb = Types::Strict::String.enum(
    'GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'
  )

  NsqSupportedVerb = Types::Strict::String.enum(
    'DELETE', 'POST', 'PUT', 'PATCH'
  )

  class RoutingConfig < Dry::Struct::Value
    attribute :path, Types::Strict::String

    def request_handler
      raise NotImplementedError
    end
  end

  class HttpRoutingConfig < RoutingConfig
    attribute :verb, HttpSupportedVerb
    attribute :http do
      attribute :host, Types::Strict::String
    end

    def request_handler
      ::RequestHandlers::HTTPForward.new(destination_host: http.host)
    end
  end

  class NsqRoutingConfig < RoutingConfig
    attribute :verb, NsqSupportedVerb
    attribute :nsq do
      attribute :topic, Types::Strict::String
    end

    def request_handler
      ::RequestHandlers::NsqForward.new(topic: nsq.topic)
    end
  end

  class ProxyResponse < Dry::Struct::Value
    attribute :status, Types::Strict::Integer
    attribute :headers, Types::Hash
    attribute :body, Types::String

    def to_rack
      [status, headers, [body.to_s]]
    end
  end

  RoutingConfigList = Types::Strict::Array.of(HttpRoutingConfig | NsqRoutingConfig)
end
