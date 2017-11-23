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
            header = params.env['HTTP_AUTHORIZATION']
            token = params.raw[:token] || params.raw['token']

            jwt = if header
              EchoCommon::Services::Jwt.from_http_header header
            elsif token
              EchoCommon::Services::Jwt.decode token
            end

            raise JWT::ExpiredSignature if jwt.nil?
            jwt
          end
        end

        def encode_as_jwt(payload)
          EchoCommon::Services::Jwt.encode payload
        end
      end
    end
  end
end
