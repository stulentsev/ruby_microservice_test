# frozen_string_literal: true

require 'import'

module RequestHandlers
  class NsqForward

    include Import['logger']
    include Import['rack_helpers.read_body']
    include Import[nsq_router: 'routers.nsq']

    # dummy import to inject the topic
    include Import[topic: 'types.null']

    def call(env)
      # handle params matched from the router
      # /drivers/:id => [:id] param
      path_params = env.fetch('router.params', {})
      body        = read_body.call(env)

      nsq_router.call(
        params: path_params,
        body: body,
        topic: topic
      ).to_rack
    end
  end
end
