# frozen_string_literal: true

Application.boot(:location_service) do |app|
  init do
    app.register('location_service.url') do
      ENV.fetch('LOCATION_SERVICE_URL', 'http://driver-location.local:3000')
    end
  end
end
