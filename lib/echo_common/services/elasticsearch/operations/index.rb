module EchoCommon
  module Services
    class Elasticsearch
      module Operations
        module Index
          def delete_all_indices
            @client.delete_all_indices
          end

          def create_all_indices
            @client.create_all_indices
          end

          def delete_index
            @client.delete_index(@index)
          end

          def create_index
            @client.create_index(@index)
          end

          def put_alias(index:, name:, body: {})
            @client.indices.put_alias index: index, name: name, body: body
          end
        end
      end
    end
  end
end
