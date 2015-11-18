require 'echo_common/error'

module EchoCommon
  module Lotus
    module Routing
      module Parsing
        #
        # * Use JSON parser when mime_type is 'application/vnd.api+json'
        # * Raise a specific error for body parsing, not JSON::ParseError.
        #   The reason for this is that we want to distinguish a JSON parse
        #   error which happened when parsing the request body and a parse
        #   error which happened at any other time (for instance poorly written
        #   lib which leaks a JSON::ParseError at a later time than the body was parsed).
        #
        module VndJsonParseSupportAndBodyParseError
          class BodyParseError < ::JSON::ParserError; end

          def mime_types
            # After v0.4.3 of lotus router this is no longer an issue.
            if defined? Lotus::Router
              unless Lotus::Router::VERSION == "0.4.3"
                fail EchoCommon::Error,
                  "Please verify that we still need this patch, adding support for application/vnd.api+json #{__FILE__}."
              end
            end

            ['application/json', 'application/vnd.api+json']
          end

          def parse(body)
            JSON.parse(body)
          rescue JSON::ParserError
            raise BodyParseError
          end
        end
      end
    end
  end
end
