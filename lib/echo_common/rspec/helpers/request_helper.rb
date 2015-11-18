require 'database_cleaner'

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

unless defined? ::Lotus::Container
  fail EchoCommon::Error, "Didn't find Lotus::Container"
end

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

            let(:disable_db_clean) { false }

            before do
              unless disable_db_clean
                DatabaseCleaner.start
              end
            end

            after do
              unless disable_db_clean
                DatabaseCleaner.clean
              end
            end


            let :app do
              ::Lotus::Container.new
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
          post url, body.to_json, rack_env
        end

        def put_json(url, body = {}, rack_env = auth_header)
          rack_env["CONTENT_TYPE"] = "application/json"
          put url, body.to_json, rack_env
        end
      end



    end
  end
end
