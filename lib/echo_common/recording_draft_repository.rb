require_relative 'recording_draft'
require_relative 'elasticsearch_base_repository'

module EchoCommon
  class RecordingDraftRepository < ElasticsearchBaseRepository
    class << self

      def clear
        super
        service.add_alias
      end

      private

      def entity_class
        RecordingDraft
      end

      def index_type
        'recording_draft'
      end

      def index_name
        'recording_drafts'
      end
    end
  end
end
