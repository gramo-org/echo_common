require_relative 'merge_in_id'

module EchoCommon
  module Services
    class Elasticsearch
      module Operations
        module Query
          include MergeInId

          # Wraps elasticsearch client 'search' method and returns the hits property
          # of the result.
          #
          # Example client response:
          #  {
          #    "took"=>68,
          #    "timed_out"=>false,
          #    "_shards"=>{"total"=>5, "successful"=>5, "failed"=>0},
          #    "hits"=>{
          #      "total"=>0,
          #      "max_score"=>nil,
          #      "hits"=>[]
          #    }
          #  }
          def search(query_body, **args)
            result = @client.search(
              index: @query_index,
              body: query_body,
              **args
            )

            result[:hits].map! do |hit|
              hit[:_source] = merge_id_into_source_and_return_source hit
              hit
            end

            result
          end

          # Wraps elasticsearch client 'suggest' method and returns the response from the client
          #
          # Example of usage:
          #
          # service.suggest({
          #   main_artist_suggests: {
          #     text: "the",
          #     completion: {
          #       field: "main_artist_suggest",
          #       size: 10
          #     }
          #   }
          # })
          #
          # Example client response:
          #
          # {
          #   "_shards": {
          #     "total": 5,
          #     "successful": 5,
          #     "failed": 0
          #   },
          #   "main_artist_suggests": [
          #     {
          #       "text": "the",
          #       "offset": 0,
          #       "length": 3,
          #       "options": [
          #         {
          #           "text": "THE BEATLES",
          #           "score": 4
          #         },
          #         {
          #           "text": "THE ROLLING STONES",
          #           "score": 4
          #         }
          #       ]
          #     }
          #   ]
          # }
          #
          # Returns symbolized hash
          #
          # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters-completion.html
          def suggest(suggestions)
            @client.suggest(
              index: @index,
              body: suggestions
            )
          end
        end
      end
    end
  end
end
