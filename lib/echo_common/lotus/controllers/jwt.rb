require 'echo_common/error'
require 'echo_common/services/jwt'

module EchoCommon
  module Lotus
    module Controllers
      module Jwt
        class JwtError < EchoCommon::Error; end

        def jwt
          header = params.env['HTTP_AUTHORIZATION']
          halt 401, "Signature has expired" if header.nil?

          @jwt ||= EchoCommon::Services::Jwt.from_http_header header
        rescue JWT::DecodeError
          raise Jwt::JwtError
        end

        def encode_as_jwt(payload)
          EchoCommon::Services::Jwt.encode payload
        end
      end
    end
  end
end
