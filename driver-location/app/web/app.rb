# frozen_string_literal: true

require 'import'
require 'sinatra'

module Web
  class App < Sinatra::Base
    include Import['web.recent_locations']
    include Import[json_generator: 'json.generator']

    configure do
      enable :logging
      use Rack::CommonLogger, Application['logger']
    end

    not_found do
      content_type :text
      status 404
      body 'Not found'
    end

    get '/drivers/:id/locations' do
      content_type 'application/json'

      recent_locations.call(
        user_id: params[:id],
        minutes: params[:minutes]
      ) do |m|
        m.success do |data|
          status 200
          body json_generator.call(data).value!
        end
        m.failure do |err|
          status 422
          body json_generator.call(errors: err).value!
        end
      end
    end
  end
end
