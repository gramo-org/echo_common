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
            # TODO; Use request_store gem?
            after :clear_current_user!
          end
        end

        private

        def authenticate!(request, response)
          set_current_user_id(request)
          set_current_user_locale(request)

          halt 401 unless authenticated?(request)
        end

        def clear_current_user!(_request, _response)
          Thread.current[:current_user_id] = nil
          Thread.current[:current_user_locale] = nil
        end

        def authenticated?(request)
          jwt(request).get('data.authenticated') == true && !current_user_id.nil?
        rescue JWT::DecodeError
          false
        end

        def set_current_user_id(request)
          Thread.current[:current_user_id] = begin
            jwt(request).get('data.user.id')
          rescue JWT::DecodeError
            nil
          end
        end

        def set_current_user_locale(request)
          Thread.current[:current_user_locale] = begin
            jwt(request).get('data.user.locale')
          rescue JWT::DecodeError
            nil
          end
        end

        def current_user_id
          Thread.current[:current_user_id]
        end

        def current_user_locale
          Thread.current[:current_user_locale]
        end
      end
    end
  end
end
