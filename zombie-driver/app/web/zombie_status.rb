require 'import'

module Web
  class ZombieStatus
    include Dry::Transaction

    include Import['location_service.recent_locations']
    include Import['zombie.constants.period_in_minutes']
    include Import[zombie_status_checker: 'zombie.status']

    UserZombieStatusCommandSchema = Dry::Validation.Params do
      required(:id).filled { int? | str? }
    end

    step :validate
    step :calculate_status

    private

    def validate(params)
      UserZombieStatusCommandSchema.call(params).to_monad
    end

    def calculate_status(params)
      fetch_locations(params[:id]).bind do |response|
        check_zombie_status(response.locations).bind do |status|
          Success(zombie: status, minutes: period_in_minutes)
        end
      end
    end

    def fetch_locations(id)
      recent_locations
        .call(id: id, minutes: period_in_minutes)
        .or(Failure(:remote_service_error))
    end

    def check_zombie_status(locations)
      zombie_status_checker
        .call(location_list: locations)
        .or(Failure(:not_enough_locations_error))
    end
  end
end
