require_relative 'release_draft'
require_relative 'elasticsearch_base_repository'

module EchoCommon
  class ReleaseDraftRepository < ElasticsearchBaseRepository
    class << self
      private

      def entity_class
        ReleaseDraft
      end

      def index_type
        'release_draft'
      end

      def index_name
        'release_drafts'
      end
    end
  end
end
