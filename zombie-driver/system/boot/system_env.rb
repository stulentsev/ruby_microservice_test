# frozen_string_literal: true

Application.boot(:system_env) do |container|
  start do
    container.register('system_env') { ENV }
  end
end
