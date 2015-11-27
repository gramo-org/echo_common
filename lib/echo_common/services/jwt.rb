require 'jwt'

module EchoCommon
  module Services
    class Jwt
      # Default config to read jwt_key, jwt_key_pub and jwt_alg from
      # when you call .encode and .decode
      def self.default_config
        @@echo_config
      end

      def self.default_config=(config)
        @@echo_config = config
      end

      # Decode and return a Jwt::Token object from given HTTP header.
      def self.from_http_header(header)
        token = header.sub(/Bearer /, '')
        decode token
      end

      # Creates JWT token to be used as session object.
      #
      # Arguments
      #   user          - A user object, responding to #to_hash which returns the attributes to
      #                   be serialized.
      #   exp           - Expiration time
      #   config        - A configuration object where jwt_alg, jwt_key and jwt_key_pub are found.
      def self.create_session_token(user:, exp:, config: default_config)
        encode(
          {
            data: {
              authenticated: true,
              user: user.to_hash
            },
            exp: exp
          },
        config: config
        )
      end

      # Encode a payload as JWT
      #
      # @param payload [Object] the object to be encoded in the token
      # @return [String] a JWT encoded string
      def self.encode(payload, config: default_config)
        JWT.encode payload, config[:jwt_key], config[:jwt_alg]
      end

      # Decode the given JWT String using the configured algorithm
      #
      # @param jwt_string [String] the JWT to decode
      # @return [Echo::Services::Jwt::Token]
      def self.decode(jwt_string, config: default_config)
        decoded = JWT.decode jwt_string, config[:jwt_key_pub], algorithm: config[:jwt_alg]

        Token.new decoded
      end

      # Interface for working with payload from a decoded JWT.
      # Contains a header and payload. The header is accessed explicitly
      # while the object itself gives access to the payload via [] and get.
      #
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

        def to_hash
          @payload
        end
        alias to_h to_hash

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
