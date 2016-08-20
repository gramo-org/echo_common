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
        class JwtError < EchoCommon::Error; end

        def jwt
          @jwt ||= begin
            token = nil

            jwt = if header = params.env['HTTP_AUTHORIZATION']
              EchoCommon::Services::Jwt.from_http_header header
            elsif token = params.raw[:token]
              EchoCommon::Services::Jwt.decode token
            end

            halt 401, "Signature has expired" if jwt.nil?
            jwt
          end
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
