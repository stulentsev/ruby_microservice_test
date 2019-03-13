module Common
  module HTTPClient
    module Errors
      BaseError    = Class.new(StandardError)
      TimeoutError = Class.new(BaseError)
      NetworkError = Class.new(BaseError)
      ClientError  = Class.new(BaseError)
      ServerError  = Class.new(BaseError)
    end
  end
end
