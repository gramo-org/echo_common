module EchoCommon
  module Lotus
    module Controllers
      #
      # Provides authentication for a Lotus controller.
      #
      # Needs #jwt to provide with a JSON Token object.
      #
      # Can be included directly, or used in controller.prepare statement.
      #
      #   class App < Lotus::Application
      #     configure do
      #       controller.prepare do
      #         include Authentication
      #       end
      #     end
      #   end
      #
      # @see EchoCommon::Lotus::Controllers::SkipAuthentication
      # @see EchoCommon::Lotus::Controllers::Jwt
      # @see EchoCommon::Services::Jwt
      # @see EchoCommon::Services::Jwt::Token
      #
      module Authentication
        def self.included(base)
          base.class_eval do
            before :authenticate!
          end
        end

        private

        def authenticate!
          halt 401 unless authenticated?
        end

        def authenticated?
          jwt.get('data.authenticated') == true && !!current_user_id
        end

        def current_user_id
          jwt.get('data.user.id')
        end
      end
    end
  end
end
