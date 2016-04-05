require 'elasticsearch'
require 'echo_common/utils/hash'

module EchoCommon
  module Services
    class Elasticsearch
      class Client

        # Initializes a new wrapper client (@see ::Elasticsearch::Client)
        #
        # logger - the logger to configure on the underlying ::Elasticsearch::Client
        #
        # config - the elasticsearch configuration parameters.
        #          Holds the configuration parameters passed to the underlying client (@see ::Elasticsearch::Transport::Client.initialize),
        #          as well as some custom parameters used by our implementation.
        #
        #          Ex:
        #          {
        #            host: "127.0.0.1",
        #            port: 9200,
        #            user: "admin",
        #            password: "admin",
        #            scheme: "https",
        #            index_prefix: "staging_", # <- custom property defining the index prefix
        #            buffer_max_size: 1000, # <- custom property defining tha max size of the (@see AutoFlushingBuffer)
        #            indices_mapping_glob: "lib/config/indices/*.json" # <- custom property defining the glob to use to get mapping files
        #          }
        #
        def initialize(logger:, config:, client_class: ::Elasticsearch::Client)
          @config = config
          @indices_mapping_glob = @config.fetch(:indices_mapping_glob)
          @client = client_class.new(logger: logger, hosts: [@config])
        end

        def get(index:, type:, id:)
          symbolize @client.get(index: with_prefix(index), type: type, id: id)
        end

        def index(index:, type:, id:, body:)
          symbolize @client.index(index: with_prefix(index), type: type, id: id, body: body)
        end

        def update(index:, type:, id:, body:)
          symbolize @client.update(
            index: with_prefix(index), type: type, id: id,
            body: body
          )
        end

        def bulk(index:, type:, body:)
          symbolize @client.bulk(
            index: with_prefix(index), type: type,
            body: body
          )
        end

        def search(index:, type:, body:)
          response = @client.search(
            index: with_prefix(index), type: type,
            body: body
          )
          symbolize(response)[:hits]
        end

        def create_index(index)
          create_all_indices(filter: -> (f) { mapping_file_name(index) == f })
        end

        def create_all_indices(filter: -> (f) { true })
          mapping_files.
            select(&filter).
              map { |f| create_index_from_file(f) }
        end

        def delete_index(index)
          @client.indices.delete index: with_prefix(index), ignore: [404]
        end

        def delete_all_indices
          @client.indices.delete index: with_prefix("*")
        end

        # @see ::Elasticsearch::API::Indices::Actions.refresh
        def refresh_indices
          @client.indices.refresh
        end

        # @see ::Elasticsearch::API::Indices::Actions.put_alias
        def put_alias(index:, name:, body: {})
          @client.indices.put_alias(
            index: with_prefix(index),
            name: with_prefix(name),
            body: body
          )
        end

        private

        def with_prefix(index)
          "#{@config[:index_prefix]}#{index}"
        end

        def mapping_files
          Dir.glob(@indices_mapping_glob)
        end

        def mapping_file_name(prefixed_index)
          unprefixed_index = prefixed_index.sub(@config[:index_prefix], '')
          @indices_mapping_glob.sub('*', unprefixed_index)
        end

        def create_index_from_file(file_name)
          index_definition = File.read(file_name)
          index_name = file_name[/(\w*)\.json/, 1]

          @client.indices.create(
            index: with_prefix(index_name),
            body: index_definition
          )
        end

        def symbolize(hash)
          EchoCommon::Utils::Hash.new(hash).symbolize!
        end
      end
    end
  end
end
