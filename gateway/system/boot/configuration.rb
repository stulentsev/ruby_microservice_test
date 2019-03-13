Application.boot(:configuration) do |app|
  start do
    app.register('configuration.default_path', cache: true) do
      app.config.root.join('config.yaml')
    end

    app.register('configuration.default') do
      File.read(app['configuration.default_path'])
    end

    app.register('configuration.routing_config') do
      app['configuration_loader.yaml'].call(app['configuration.default']).value!
    end
  end
end
