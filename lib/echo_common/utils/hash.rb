require 'hanami/utils/hash'

module EchoCommon
  module Utils
    class Hash < ::Hanami::Utils::Hash

      # Stringify all keys in hash
      #
      # Overrides Hanami' #stringify! as it only traverse Hash objects.
      # If you nest a Hanami::Utils::Hash in a Hanami::Utils::Hash it does not go
      # down in to the Hanami Hash. Maybe a bug? Maybe add an issue to Hanami.
      def stringify!
        deep_transform_keys! { |k| k.to_s }
      end

      # Symbolize all keys in hash
      #
      # Overrides Hanami' #symbolize! as it only traverse Hash objects.
      # If you nest a Hanami::Utils::Hash in a Hanami::Utils::Hash it does not go
      # down in to the Hanami Hash. Maybe a bug? Maybe add an issue to Hanami.
      def symbolize!
        deep_transform_keys! { |k| k.to_sym }
      end


      # Transforms all keys with given block. Key is yielded to block
      #
      # Returns a copy of the hash
      def deep_transform_keys(&block)
        _deep_transform_keys_in_object(self, &block)
      end

      # Transforms all keys with given block. Key is yielded to block
      #
      # Mutates the hash
      def deep_transform_keys!(&block)
        _deep_transform_keys_in_object!(self, &block)
      end

      def to_s
        inspect
      end


      private

      def _deep_transform_keys_in_object(object, &block)
        case object
        when ::Hash, ::EchoCommon::Utils::Hash, ::Hanami::Utils::Hash
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
        when ::Hash, ::EchoCommon::Utils::Hash, ::Hanami::Utils::Hash
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
