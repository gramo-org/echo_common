require 'elasticsearch'
require 'echo_common/utils/hash'
require 'echo_common/error'
require 'hanami/utils/kernel'

# Enable persistent http keep-alive
# https://github.com/elastic/elasticsearch-ruby/blob/bdf5e145e5acc21726dddcd34492debbbddde568/elasticsearch-transport/README.md
require 'typhoeus'
require 'typhoeus/adapters/faraday'

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
        #           {
        #             index_prefix: "staging_",                    # <- custom property defining the index prefix
        #             indices_mapping_glob: "path/indices/*.json"  # <- custom property defining the glob to use to get mapping files. Can also be an array of files/globs
        #             hosts: [{
        #               host: "127.0.0.1",
        #               port: 9200,
        #               user: "admin",
        #               password: "admin",
        #               scheme: "https",
        #             }]
        #           }
        #
        def initialize(client_class: ::Elasticsearch::Client, **config)
          @indices_mapping_globs = ::Hanami::Utils::Kernel.Array(config.delete(:indices_mapping_glob))
          @index_prefix         = config.delete(:index_prefix)

          @client = client_class.new config
        end

        def get(index:, type:, id:)
          symbolize @client.get(index: with_prefix(index), type: type, id: id)
        end

        def mget(index:, type:, body:)
          symbolize @client.mget(index: with_prefix(index), type: type, body: body)
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

        def delete(index:, type:, id:)
          symbolize @client.delete(
            index: with_prefix(index), type: type,
            id: id
          )
        end

        def bulk(index:, type:, body:)
          symbolize @client.bulk(
            index: with_prefix(index), type: type,
            body: body
          )
        end

        def search(index:, type: nil, body:)
          response = @client.search(
            index: with_prefix(index, allow_multi_index: true), type: type,
            body: body
          )
          symbolize(response)[:hits]
        end

        def suggest(index:, body:)
          symbolize @client.suggest(
            index: with_prefix(index),
            body: body
          )
        end

        def create_index(index)
          json_file_name = mapping_file_name index
          create_all_indices(filter: -> (f) { f.end_with? json_file_name })
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
        def refresh_indices(index = "*")
          @client.indices.refresh index: with_prefix(index)
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

        ALLOWED_CHARS_IN_INDEX_NAME = '@a-z_*'.freeze

        # We only support multiple indexes listed with , now.
        # Not all of https://www.elastic.co/guide/en/elasticsearch/reference/current/multi-index.html
        def with_prefix(index, allow_multi_index: false)
          return "#{@index_prefix}#{index}" if index =~ /\A[#{ALLOWED_CHARS_IN_INDEX_NAME}]+\z/

          raise ArgumentError, "Index #{index} is not allowed" unless allow_multi_index

          if index =~ /\A[#{ALLOWED_CHARS_IN_INDEX_NAME},]+\z/
            return index.split(',').map { |index_name| with_prefix index_name }.join(',')
          end

          raise ArgumentError, "Index #{index} is unsupported."
        end

        def mapping_files
          file_paths = indices_mapping_globs.flat_map do |glob|
            Dir.glob(glob)
          end

          filenames = file_paths.map { |path| File.basename(path) }
          if filenames.uniq != filenames
            fail EchoCommon::Error.new "Your indices mapping glob yielded multiple files with equal filenames. File paths was calculated to be: #{file_paths}"
          end

          file_paths
        end

        def mapping_file_name(prefixed_index)
          prefixed_index.sub(@index_prefix, '') + '.json'
        end

        def indices_mapping_globs
          @indices_mapping_globs || fail("You must set indices_mapping_glob when initialize the client.")
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
