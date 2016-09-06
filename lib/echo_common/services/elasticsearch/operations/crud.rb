require 'echo_common/errors'

module EchoCommon
  module Services
    class Elasticsearch

      class BulkError < EchoCommon::Error
        attr_reader :response

        def initialize(response)
          @response = response
        end
      end

      module Operations
        module Crud
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
            if (result[:found])
              result[:_source]
            end
          end


          # Wraps elasticsearch client 'index' method, and returns the result
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
          def index(data)
            @client.index(
              index: @index, type: @type, id: data[:id],
              body: data
            )
          end

          # Wraps elasticsearch client 'update' method and returns the result
          # Note: this method is implemented as partial update in the client, any
          # nil values in doc will likely clear values in elasticsearch document
          def update(doc)
            @client.update(
              index: @index, type: @type, id: doc[:id],
              body: { doc: doc }
            )
          end

          # Wraps elasticsearch client 'delete' method and returns the result
          def delete(id)
            @client.delete(
              index: @index, type: @type,
              id: id
            )
          end

          # Wraps elasticsearch client 'bulk' method and returns the result
          def bulk(data)
            response = @client.bulk(
              index: @index, type: @type,
              body: data
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
