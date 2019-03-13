# frozen_string_literal: true

require 'import'

module Listener
  class Runner
    include Import['logger']
    include Import['listener.worker']

    module ServerEngineWorker
      attr_reader :worker
      attr_reader :server_engine

      def initialize
        @worker = Listener::Worker.new
      end

      def run
        worker.run(
          topic: config[:topic],
          channel: config[:channel],
          blocking: config[:blocking]
        )
      end

      def stop
        worker.stop
      end
    end

    def run(options)
      @server_engine = create_server_engine(options)
      @server_engine.run
    end

    def stop
      server_engine.stop
    end

    private

    def create_server_engine(options)
      worker_options = build_serverengine_config(options)

      ServerEngine.create(nil, ServerEngineWorker, worker_options)
    end

    def build_serverengine_config(options)
      options.merge(
        logger: logger,
        log_level: logger.level,
        worker_type: 'process',
        log_stdout: false,
        log_stderr: false,
        stop_immediately_at_unrecoverable_exit: true,
        unrecoverable_exit_codes: [1]
      )
    end
  end
end
