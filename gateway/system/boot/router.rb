Application.boot(:router) do |app|
  init do
    require 'http_router'
  end

  start do
    use :configuration
    use :logger

    app.register(:router) do
      HttpRouter.new.tap do |router|
        router.add('/health', request_method: 'GET').to(app['request_handlers.health'])
      end
    end

    app.register('router.application', cache: true) do
      app[:router].tap do |router|
        app['configuration.routing_config'].each do |route_config|
          router.add(route_config.path, request_method: route_config.verb).to(route_config.request_handler)
        end
        app[:logger].debug(router)
      end
    end

  end
end
