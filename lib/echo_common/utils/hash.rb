require 'lotus/utils/hash'

module EchoCommon
  module Utils
    class Hash < ::Lotus::Utils::Hash
      def deep_transform_keys(&block)
        _deep_transform_keys_in_object(self, &block)
      end

      def deep_transform_keys!(&block)
        _deep_transform_keys_in_object!(self, &block)
      end


      private

      def _deep_transform_keys_in_object(object, &block)
        case object
        when ::Hash, ::EchoCommon::Utils::Hash
          object.each_with_object({}) do |(key, value), result|
            result[yield(key)] = _deep_transform_keys_in_object(value, &block)
          end
        when ::Array
          object.map {|e| _deep_transform_keys_in_object(e, &block) }
        else
          object
        end
      end

      def _deep_transform_keys_in_object!(object, &block)
        case object
        when ::Hash, ::EchoCommon::Utils::Hash
          object.keys.each do |key|
            value = object.delete(key)
            object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
          end
          object
        when ::Array
          object.map! {|e| _deep_transform_keys_in_object!(e, &block)}
        else
          object
        end
      end
    end
  end
end
