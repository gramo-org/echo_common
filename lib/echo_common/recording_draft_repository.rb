require_relative 'recording_draft'

module EchoCommon
  class RecordingDraftRepository

    class << self
      def elasticsearch_service_class
        raise "Implement in subclass!"
      end

      def service
        @service ||= elasticsearch_service_class.new(
          index: 'recording_drafts',
          type: 'recording_draft'
        )
      end

      def clear
        service.delete_index
        service.create_index
        service.add_alias
      end

      def find(id)
        result = service.get id
        RecordingDraft.new result
      end

      def count
        result = service.search(size: 0)
        result.fetch :total
      end

      def create(entity_or_entities)
        entities = Array(entity_or_entities).map(&:to_h)

        if entities.any?
          service.bulk entities.map { |e| {index: {_id: e[:id], data: e}} }
        end
      end

      def delete(id_or_ids)
        ids = Array(id_or_ids)

        if ids.any?
          service.bulk ids.map { |id| {delete: {_id: id}} }
        end
      end

      def bulk(data)
        service.bulk data
      end

      def refresh_index
        service.refresh_index
      end
    end
  end
end
