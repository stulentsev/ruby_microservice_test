Application.boot(:web) do |container|
  start do
    # 24h of max query time
    container.register('web.max_minutes_query', 60 * 24)
  end
end
