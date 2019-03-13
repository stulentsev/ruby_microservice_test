# frozen_string_literal: true

require 'import'

module RequestHandlers
  class HTTPForward

    include Import['rack_helpers.extract_request_headers']
    include Import['rack_helpers.generate_proxy_headers']
    include Import['rack_helpers.read_body']
    include Import['logger']
    include Import[http_router: 'routers.http']

    # dummy import to inject the host
    include Import[destination_host: 'types.null']

    def call(env)
      request = rack_request(env)

      request_path   = request.fullpath
      request_method = request.request_method
      headers        = extract_request_headers.call(rack_env: env)
      proxy_headers  = generate_proxy_headers.call(rack_env: env)
      body           = read_body.call(env)

      # override request headers with our own proxy headers
      request_headers = headers.merge(proxy_headers)

      http_router.call(
        path: request_path,
        method: request_method.downcase.to_sym,
        headers: request_headers,
        body: body,
        destination_host: destination_host
      ).to_rack
    end

    def rack_request(env)
      Rack::Request.new(env)
    end
  end
end
