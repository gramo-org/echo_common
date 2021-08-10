require 'echo_common/error'

require_relative 'merge_in_id'

module EchoCommon
  module Services
    class Elasticsearch

      class MgetMissingIDsError < EchoCommon::Error

        def self.to_message(missing_ids)
          "mget failed due to IDs with no documents in index: #{missing_ids.join ', '}"
        end
      end

      class BulkError < EchoCommon::Error
        attr_reader :response

        def initialize(response)
          @response = response
          errors = response[:items].find_all { |i| i[:index]&.key?(:error) }
          errors = response if errors.empty?
          super "Bulk operation failed: #{errors}"
        end
      end

      module Operations
        module Crud
          include MergeInId

          # Wraps elasticsearch client 'get' method, and returns the _source
          # if document is found, or nil if not.
          #
          # Example client response:
          #   {
          #     "_index" : "twitter",
          #     "_type" : "tweet",
          #     "_id" : "1",
          #     "_version" : 1,
          #     "found": true,
          #     "_source" : {
          #         "user" : "kimchy",
          #         "postDate" : "2009-11-15T14:12:12",
          #         "message" : "trying out Elasticsearch"
          #     }
          #   }
          def get(id)
            result = @client.get index: @index, type: @type, id: id

            merge_id_into_source_and_return_source result if result[:found]
          end

          # Wraps elasticsearch client 'mget' method.
          #
          # @see #get
          def mget(ids)
            return if !ids || ids.empty?
            result = @client.mget index: @index, type: @type, body: { ids: ids }
            missing_ids =
              result[:docs].find_all { |doc| !doc[:found] }.map { |doc| doc[:_id] }
            raise MgetMissingIDsError,
                  MgetMissingIDsError.to_message(missing_ids) unless missing_ids.empty?

            result[:docs].map { |doc| merge_id_into_source_and_return_source doc }
          end

          # Wraps elasticsearch client 'index' method, and returns the result
          #
          # If id in doc is omitted Elasticsearch will assign one for you.
          #
          # Example client response:
          #   {
          #     "_shards" : {
          #         "total" : 10,
          #         "failed" : 0,
          #         "successful" : 10
          #     },
          #     "_index" : "twitter",
          #     "_type" : "tweet",
          #     "_id" : "1",
          #     "_version" : 1,
          #     "created" : true
          #   }
          def index(doc)
            @client.index(
              index: @index, type: @type, id: doc[:id],
              body: doc
            )
          end

          # Wraps elasticsearch client 'update' method and returns the result
          # Note: this method is implemented as partial update in the client, any
          # nil values in doc will likely clear values in elasticsearch document
          def update(id:, **doc)
            @client.update(
              index: @index, type: @type, id: id,
              body: { doc: doc }
            )
          end

          # A version of update that is more true to the interface of
          # the real Elasticsearch client.
          def not_so_stupid_update(args)
            @client.update(index: @index, type: @type, **args)
          end

          # Wraps elasticsearch client 'delete' method and returns the result
          def delete(id)
            @client.delete(
              index: @index, type: @type,
              id: id
            )
          end

          # Wraps elasticsearch client 'bulk' method and returns the result
          def bulk(data, **options)
            response = @client.bulk(
              index: @index, type: @type,
              body: data,
              **options
            )

            if response[:errors]
              raise BulkError.new response
            end

            response
          end
        end
      end
    end
  end
end
