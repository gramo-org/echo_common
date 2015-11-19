require 'securerandom'

module EchoCommon
  module Middleware
    # Middleware component that exposes a unique id per request
    # Will use HTTP_HEROKU_REQUEST_ID if on heroku, otherwise a SecureRandom.uuid is used.
    # Enable by adding the following to config.ru
    #
    #    use Echo::Middleware::RequestId
    #
    class RequestId
      def initialize(app)
        @app = app
      end

      def call(env)
        Thread.current[:echo_request_id] = env.fetch('HTTP_HEROKU_REQUEST_ID', SecureRandom.uuid)
        @app.call(env)
      ensure
        Thread.current[:echo_request_id] = nil
      end
    end
  end
end
