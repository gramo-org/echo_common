require 'rack/test'
require 'database_cleaner'
require 'echo_common/rspec/helpers/db_clean_helper'

module EchoCommon
  module RSpec
    module Helpers
      #
      # Takes care of include rack test methods + ensure database is cleaned.
      # If you don't want DB cleaned, set disable_db_clean to true.
      #
      module RequestHelper
        def self.included(base)
          base.class_eval do
            include Rack::Test::Methods
            include EchoCommon::RSpec::Helpers::DbCleanHelper

            let(:app) do
              ::Hanami.app
            end
          end
        end

        def last_response_json
          JSON.parse last_response.body
        rescue JSON::ParserError => error
          raise "Parse last body's response as JSON failed. Error was: '#{error}'. Body was: #{last_response.body}"
        end

        def get_json(url, query = {}, rack_env = auth_header)
          rack_env["CONTENT_TYPE"] = "application/json"
          get url, query, rack_env
        end

        def post_json(url, body = {}, rack_env = auth_header)
          rack_env["CONTENT_TYPE"] = "application/json"
          post url, _to_json_unless_already_string(body), rack_env
        end

        def put_json(url, body = {}, rack_env = auth_header)
          rack_env["CONTENT_TYPE"] = "application/json"
          put url, _to_json_unless_already_string(body), rack_env
        end

        def patch_json(url, body = {}, rack_env = auth_header)
          rack_env["CONTENT_TYPE"] = "application/json"
          patch url, _to_json_unless_already_string(body), rack_env
        end

        def delete_json(url, query = nil, rack_env = auth_header)
          rack_env["CONTENT_TYPE"] = "application/json"
          if query
            url << "?" << URI.encode_www_form(query)
          end
          delete url, {}, rack_env
        end

        private

        def _to_json_unless_already_string(body)
          if body.is_a? String
            body
          else
            body.to_json
          end
        end
      end
    end
  end
end
