# frozen_string_literal: true

require 'sinatra'

module Web
  class App < Sinatra::Base
    def json_generator
      Application.resolve('json.generator')
    end

    def zombie_status_service
      Application.resolve('web.zombie_status')
    end

    set :logger, Application['logger']

    configure do
      enable :logging
    end

    not_found do
      content_type :text
      status 404
      body 'Not found'
    end

    get '/health' do
      content_type :json
      status 200

      body json_generator.call(
        status: :ok,
        app_name: Application.config.name
      ).value!
    end

    get '/drivers/:id' do
      content_type :json

      zombie_status_service.call(params) do |m|
        m.success do |result|
          status 200
          body   json_generator.call(result).value!
        end

        m.failure :validate do |err|
          status 422
          body   json_generator.call(err).value!
        end

        m.failure do |err|
          case err
          when :remote_service_error
            status 503
          when :not_enough_locations_error
            status 422
            body json_generator.call(
              errors: { id: "Can't determine zombie status!" }
            ).value!
          else
            status 500
          end
        end
      end
    end

  end
end
