require_relative 'release_draft'

module EchoCommon
  class ElasticsearchBaseRepository
    class << self
      def elasticsearch_service_class
        raise "Implement in subclass!"
      end

      def service
        @service ||= elasticsearch_service_class.new index: index_name, type: index_type
      end

      def clear
        service.delete_index
        service.create_index
      end

      def refresh_index
        service.refresh_index
      end

      def find(id)
        result = service.get id
        entity_class.new result if result
      end

      def count
        result = service.search size: 0
        result.fetch :total
      end

      def create(entity_or_entities)
        entities = Array(entity_or_entities).map(&:to_h)

        bulk entities.map { |e| { index: { _id: e[:id], data: e } } } if entities.any?
      end

      def delete(id_or_ids)
        ids = Array(id_or_ids)

        bulk ids.map { |id| { delete: { _id: id } } } if ids.any?
      end

      def bulk(data)
        service.bulk data
      end

      private

      def entity_class
        raise 'Need to implement in subclass!'
      end

      def index_type
        raise 'Need to implement in subclass!'
      end

      def index_name
        raise 'Need to implement in subclass!'
      end
    end
  end
end
