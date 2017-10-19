require 'echo_common/error'
require 'echo_common/services/jwt'

module EchoCommon
  module Hanami
    module Controllers
      #
      # Provides a #jwt method on controllers.
      #
      # @see EchoCommon::Hanami::Controllers::Authentication
      #
      module Jwt
        def jwt
          @jwt ||= begin
            token = nil

            if header = params.env['HTTP_AUTHORIZATION']
              EchoCommon::Services::Jwt.from_http_header header
            elsif token = params.raw[:token] || params.raw['token']
              EchoCommon::Services::Jwt.decode token
            end
          rescue JWT::ExpiredSignature
            halt 401, "Signature has expired"
          end
        end

        def encode_as_jwt(payload)
          EchoCommon::Services::Jwt.encode payload
        end
      end
    end
  end
end
