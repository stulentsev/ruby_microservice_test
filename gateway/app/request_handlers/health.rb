# frozen_string_literal: true

module RequestHandlers
  class Health
    def call(*)
      [
        200,
        { 'Content-Type' => 'application/json' },
        [%({"status":"ok","app_name":"#{Application.config.name}"})]
      ]
    end
  end
end

