require 'jwt'

module EchoCommon
  module Services
    class Jwt
      def self.from_http_header(header)
        token = header.sub(/Bearer /, '')
        decode token
      end

      # Encode a payload as JWT
      # @param payload [Object] the object to be encoded in the token
      # @return [String] a JWT encoded string
      def self.encode(payload, config: Echo.config)
        JWT.encode payload, config[:jwt_key], config[:jwt_alg]
      end

      # Decode the given JWT String using the configured algorithm
      # @param jwt_string [String] the JWT to decode
      # @return [Echo::Services::Jwt::Token]
      def self.decode(jwt_string, config: Echo.config)
        decoded = JWT.decode jwt_string, config[:jwt_key_pub], algorithm: config[:jwt_alg]

        Token.new decoded
      end

      # Interface for working with payload from a decoded JWT.
      # Contains a header and payload. The header is accessed explicitly
      # while the object itself gives access to the payload via [] and get.
      # @example
      #     token = Token.new decoded_jwt
      #     token['data']
      #     token['data']['attributes']
      #     token.get("data")
      #     token.get("data.attributes.nested_attribute")
      class Token
        def initialize(decoded)
          @payload = decoded[0].to_h
          @header = decoded[1].to_h
        end

        def [](key)
          @payload.fetch(key)
        end

        def get(key)
          key, *keys = key.to_s.split('.')
          result     = self[key]

          Array(keys).each do |k|
            break if result.nil?
            result = result[k]
          end

          result
        end

        def header
          @header
        end

        def to_h
          @payload
        end
      end
    end
  end
end
