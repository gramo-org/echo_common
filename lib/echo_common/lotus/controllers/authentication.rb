module EchoCommon
  module Lotus
    module Controllers
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
