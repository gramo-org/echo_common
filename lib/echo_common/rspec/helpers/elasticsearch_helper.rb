require 'elasticsearch/extensions/test/cluster'
require 'echo_common/services/elasticsearch'

module EchoCommon
  module RSpec
    module Helpers
      module ElasticsearchHelper
        # Block or proxy the calls to client based on configuration
        class BlockingProxyClient
          @@route = false
          @@blocked = false

          def self.blocked?
            @@blocked
          end

          def self.block!
            @@blocked = true
          end


          def self.route
            @@route
          end

          def self.route=(route)
            @@route = route
          end

          def initialize(target:)
            @target = target
          end

          # Because objects are not searchable immediately, explicitly refresh index
          def force_refresh_indices
            @target.refresh_indices
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
            if [:index, :update].include? method
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

              around do |example|
                begin
                  TestCluster.start
                  BlockingProxyClient.route = true
                  EchoCommon::Services::Elasticsearch.create_all_indices
                  example.run
                ensure
                  EchoCommon::Services::Elasticsearch.delete_all_indices
                  BlockingProxyClient.route = false
                end
              end
            end
          end

          class TestCluster
            @@started = false

            def self.started
              @@started ||= !!begin
                JSON.parse(Net::HTTP.get(URI("http://#{cluster_config[:network_host]}:#{cluster_config[:port]}/_cluster/health")))
              rescue
                nil
              end
            end

            def self.start
              unless self.started
                Elasticsearch::Extensions::Test::Cluster.start cluster_config
                at_exit do
                  TestCluster.stop
                end
              end
              @@started = true
            end
            def self.stop
              Elasticsearch::Extensions::Test::Cluster.stop cluster_config
            end

            def self.config=(config)
              @@config = config
            end

            def self.cluster_config
              {
                path_logs: File.join(__dir__, "../../tmp" ),
                nodes: 1,
                network_host: @@config.fetch(:host),
                port: @@config.fetch(:port),
                multicast_enabled: false
              }
            end
          end
        end
      end
    end
  end
end
