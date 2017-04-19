require 'echo_common/services/elasticsearch'

module EchoCommon
  module RSpec
    module Helpers
      module ElasticsearchHelper
        # Block or proxy the calls to client based on configuration
        class BlockingProxyClient
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

            result = @target.send(method, *args, &block)
            if [:index, :update, :delete, :bulk].include? method
              @@dirty_indices << args[0][:index]
              force_refresh_indices
            end
            result
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
              include ElasticsearchSpecHelper

              before :all do
                BlockingProxyClient.with_route do
                  setup_and_refresh_indices
                end
              end

              around :each do |example|
                BlockingProxyClient.with_route do
                  clear_dirty_indices
                  example.run
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
