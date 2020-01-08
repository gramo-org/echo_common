module EchoCommon
  module Services
    class Elasticsearch
      module MergeInId
        private

        def merge_id_into_source_and_return_source(o)
          o[:_source].merge(id: o.fetch(:_id))
        end
      end
    end
  end
end
