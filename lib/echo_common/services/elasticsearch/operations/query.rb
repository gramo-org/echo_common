module EchoCommon
  module Services
    class Elasticsearch
      module Operations
        module Query
          def self.included(base)
            base.class_eval do
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
              def search(query_body)
                @client.search(
                  index: @query_index,
                  body: query_body
                )
              end
            end
          end
        end
      end
    end
  end
end
