require 'echo_common/services/jwt'
require 'securerandom'

module EchoCommon
  module RSpec
    module Helpers
      module JwtAuthHelper
        # Returns the HTTP header which can be used for an authorized dummy user.
        def auth_token(payload = nil)
          if payload.nil?
            test_user = {
              id: SecureRandom.uuid,
              name: 'Herp Derp',
              email: 'herpderp@skalar.no'
            }

            payload = {data: {authenticated: true, user: test_user}}
          end

          EchoCommon::Services::Jwt.encode payload
        end

        def auth_header(payload = nil)
          Hash['HTTP_AUTHORIZATION' => "Bearer #{auth_token(payload)}"]
        end
      end
    end
  end
end
