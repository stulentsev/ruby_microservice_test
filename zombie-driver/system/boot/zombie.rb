# frozen_string_literal: true

Application.boot(:zombie) do |app|
  start do
    use :constants

    # can fetch a new value for the constant from the store
    app.register('zombie.constants.distance_in_meters_threshold_resolver', call: false) do
      Types::Coercible::Integer[
        app['constants.store'].fetch(:distance_in_meters_threshold) || 500
      ]
    end

    # cached value at app boot
    app.register('zombie.constants.distance_in_meters_threshold', memoize: true) do
      app['zombie.constants.distance_in_meters_threshold_resolver'].call
    end

    # can fetch a new value for the constant from the store
    app.register('zombie.constants.period_in_minutes_resolver', call: false) do
      Types::Coercible::Integer[
        app['constants.store'].fetch(:period_in_minutes) || 5
      ]
    end

    # cached value at app boot
    app.register('zombie.constants.period_in_minutes', memoize: true) do
      app['zombie.constants.period_in_minutes_resolver'].call
    end

  end
end
