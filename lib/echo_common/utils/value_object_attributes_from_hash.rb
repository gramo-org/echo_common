module EchoCommon
  module Utils
    module ValueObjectAttributesFromHash
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def property(name, &block)
          define_method name do
            value = @attributes.fetch name.to_s
            value = block.call value if block
            value
          end
        end
      end

      def initialize(attributes)
        @attributes = attributes
        @attributes.freeze
      end

      def eql?(other)
        other.is_a?(self.class) && other.to_h == to_h
      end
      alias equal? eql?
      alias == eql?

      def to_h
        @attributes
      end
    end
  end
end
