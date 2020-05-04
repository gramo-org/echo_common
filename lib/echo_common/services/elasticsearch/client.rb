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
      class Client # rubocop:disable Metrics/ClassLength
        class IndexShardsError < ::EchoCommon::Error; end
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
          @number_of_replicas = config.delete(:number_of_replicas)

          @client = client_class.new config
        end

        def get(index:, **options)
          symbolize @client.get(index: with_prefix(index), **options)
        end

        def mget(index:, **options)
          symbolize @client.mget(index: with_prefix(index), **options)
        end

        def index(index:, **options)
          symbolize @client.index(index: with_prefix(index), **options)
        end

        # @param retry_on_conflict - by default Elastic sets this value to 0.
        def update(index:, retry_on_conflict: 0, **options)
          symbolize @client.update(
            index: with_prefix(index),
            retry_on_conflict: retry_on_conflict,
            **options
          )
        end

        def delete(index:, **options)
          symbolize @client.delete(
            index: with_prefix(index),
            **options
          )
        end

        def bulk(index:, **options)
          symbolize @client.bulk(
            index: with_prefix(index),
            **options
          )
        end

        def search(index:, suppress_shards_failures: false, **options)
          response = @client.search(index: with_prefix(index, allow_multi_index: true), **options)

          if !suppress_shards_failures && response && response['_shards']['failures']
            raise IndexShardsError, response['_shards']['failures']
          end

          symbolize(response)[:hits]
        end

        def suggest(index:, **options)
          options = [suggest: options] unless options[:suggest]
          symbolize @client.search(
            index: with_prefix(index),
            **options
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

        # @see ::Elasticsearch::API::Indices::Actions#refresh
        def refresh_indices(index = "*", **options)
          @client.indices.refresh(
            index: with_prefix(index),
            **options
          )
        end

        # @see ::Elasticsearch::API::Indices::Actions#put_alias
        def put_alias(index:, name:, body: {}, **options)
          @client.indices.put_alias(
            index: with_prefix(index),
            name: with_prefix(name),
            body: body,
            **options
          )
        end

        # @see ::Elasticsearch::API::Indices::Actions#put_mapping
        def put_mapping(index:, body: {}, **options)
          @client.indices.put_mapping(
            index: with_prefix(index),
            body: body,
            **options
          )
        end

        # @see ::Elasticsearch::API::Actions#update_by_query
        def update_by_query(index:, wait_for_completion: true, **options)
          symbolize @client.update_by_query(
            index: with_prefix(index),
            wait_for_completion: wait_for_completion,
            **options
          )
        end

        def list_tasks(**options)
          symbolize @client.tasks.list(**options)
        end

        private

        # We only support multiple indexes listed with , now.
        # Not all of https://www.elastic.co/guide/en/elasticsearch/reference/current/multi-index.html
        # When index is an Array, adds prefix to each element
        def with_prefix(index, allow_multi_index: false)
          return index.map(&method(:with_prefix)) if index.is_a?(Array)
          return "#{@index_prefix}#{index}" if index.index(',').nil?

          raise ArgumentError, "Index #{index} is not allowed" unless allow_multi_index

          if index =~ /\A[@a-z0-9_*,]+\z/
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
          prefixed_index.sub(@index_prefix, '') + '.json.erb'
        end

        def indices_mapping_globs
          @indices_mapping_globs || fail("You must set indices_mapping_glob when initialize the client.")
        end

        def create_index_from_file(file_name)
          index_definition_template = File.read(file_name)
          renderer = ERB.new(index_definition_template)
          data = Struct.new(:number_of_replicas).new(@number_of_replicas)
          index_definition = renderer.result(data.send(:binding))
          index_name = file_name[/(\w*)\.json\.erb/, 1]

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
