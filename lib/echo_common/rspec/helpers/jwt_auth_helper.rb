require 'echo_common/services/jwt'

module EchoCommon
  module RSpec
    module Helpers
      module JwtAuthHelper
        # Returns the HTTP header which can be used for an authorized dummy user.
        def auth_header(payload = nil)
          if !payload
            test_user = {
              id: SecureRandom.uuid,
              name: 'Herp Derp',
              email: 'herpderp@skalar.no'
            }

            payload = {data: {authenticated: true, user: test_user}}
          end

          token = EchoCommon::Services::Jwt.encode payload

          Hash['HTTP_AUTHORIZATION' => "Bearer #{token}"]
        end
      end
    end
  end
end
