# frozen_string_literal: true

Application.boot(:constants) do |container|
  start do
    #container.register('system_env') { ENV }
  end
end
