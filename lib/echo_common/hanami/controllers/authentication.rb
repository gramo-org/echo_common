module EchoCommon
  module Hanami
    module Controllers
      #
      # Provides authentication for a Hanami controller.
      #
      # Needs #jwt to provide with a JSON Token object.
      #
      # Can be included directly, or used in controller.prepare statement.
      #
      #   class App < Hanami::Application
      #     configure do
      #       controller.prepare do
      #         include Authentication
      #       end
      #     end
      #   end
      #
      # @see EchoCommon::Hanami::Controllers::SkipAuthentication
      # @see EchoCommon::Hanami::Controllers::Jwt
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
          jwt.get('data.authenticated') == true && !current_user_id.nil?
        rescue JWT::ExpiredSignature
          false
        end

        def current_user_id
          jwt.get('data.user.id')
        rescue JWT::ExpiredSignature
          nil
        end

        def current_user_locale
          jwt.get('data.user.locale')
        rescue JWT::ExpiredSignature
          nil
        end
      end
    end
  end
end
