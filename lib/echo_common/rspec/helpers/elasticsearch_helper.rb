require 'echo_common/services/elasticsearch'

module EchoCommon
  module RSpec
    module Helpers
      module ElasticsearchHelper
        # Block or proxy the calls to client based on configuration
        class BlockingProxyClient
          KNOWN_CLIENT_METHODS = [
            :get, :mget, :index, :update, :delete, :bulk, :search, :suggest,
            :create_index, :create_all_indices, :delete_index,
            :delete_all_indices, :refresh_indices, :put_alias
          ].freeze

          METHODS_THAT_REQUIRE_REFRESH = [
            :search, :suggest
          ].freeze

          @@route = false
          @@blocked = false
          @@dirty_indices = []

          def self.blocked?
            @@blocked
          end

          def self.block!
            @@blocked = true
          end

          def self.with_route
            @@route = true
            yield
          ensure
            @@route = false
          end

          def self.route
            @@route
          end

          def initialize(target:)
            @target = target
          end

          # Because objects are not searchable immediately, explicitly refresh index
          def force_refresh_indices
            @target.refresh_indices
          end

          def self.clear_and_return_all_dirty_indices
            dirty = @@dirty_indices.dup
            @@dirty_indices.clear
            dirty.uniq
          end

          def method_missing(method, *args, &block)
            ensure_expected method

            if self.class.blocked?
              fail ArgumentError, %Q(
                The '#{method}' method on Elasticsearch client was invoked in test context.
                All interaction with Elasticsearch is disabled in this test suite.
              )
            end

            unless self.class.route
              fail ArgumentError, %Q(
                The '#{method}' method on Elasticsearch client was invoked in test context.
                Make sure that this was intentional, and enable the ElasticsearchSpecHelper:

                describe "something", enable_elastic_search: true do
                  expect(the_inquisition).to be(:spanish)
                end
              )
            end

            force_refresh_indices if METHODS_THAT_REQUIRE_REFRESH.include? method

            @target.send(method, *args, &block).tap do |result|
              is_dirty = [:index, :update, :delete, :bulk].include? method
              @@dirty_indices << args[0][:index] if is_dirty

              result
            end
          end

          def ensure_expected(method)
            return if KNOWN_CLIENT_METHODS.include? method

            fail ArgumentError, %Q(
              Unexpected method '#{method}' invoked on client.
              You need to register the method in `KNOWN_CLIENT_METHODS`.
              If the method requires a forced refresh before invoking (e.g. :search and :suggest)
              then you need to register it in `METHODS_THAT_REQUIRE_REFRESH` as well
            )
          end
        end


        module Disable
          def self.included(base)
            base.class_eval do
              include ElasticsearchSpecHelper

              BlockingProxyClient.block!
            end
          end
        end

        module Enable
          def self.included(base)
            base.class_eval do
              @@indices_setup = false

              include ElasticsearchSpecHelper

              around :each do |example|
                unless @@indices_setup
                  BlockingProxyClient.with_route do
                    setup_and_refresh_indices
                  end

                  @@indices_setup = true
                end

                BlockingProxyClient.with_route do
                  begin
                    example.run
                  ensure
                    clear_dirty_indices
                  end
                end
              end
            end
          end

          # placeholder hook, overridden in echo
          def setup_query_alias; end

          def setup_and_refresh_indices
            EchoCommon::Services::Elasticsearch.delete_all_indices
            EchoCommon::Services::Elasticsearch.client.refresh_indices

            EchoCommon::Services::Elasticsearch.create_all_indices
            setup_query_alias
            EchoCommon::Services::Elasticsearch.client.refresh_indices
          end

          def clear_dirty_indices
            dirty_indices = BlockingProxyClient.clear_and_return_all_dirty_indices
            return if dirty_indices.empty?

            dirty_indices.each do |index|
              EchoCommon::Services::Elasticsearch.delete_index(index)
              EchoCommon::Services::Elasticsearch.create_index(index)
            end
            setup_query_alias
            EchoCommon::Services::Elasticsearch.client.refresh_indices
          end
        end
      end
    end
  end
end
