require 'echo_common/utils/hash'

module EchoCommon
  module Utils
    # Adds simple DSL for define a value object with values backed by a single hash
    #
    # Example of usage
    # ================
    #
    # class SomeClass
    #   include EchoCommon::Utils::ValueObjectAttributesFromHash
    #
    #   property(:id)
    #   property(:recording) { |v| Recording.new v }
    #   property(:airing, default: nil) { |v| Airing.new v unless v.nil? }
    #   property(:starts_at) { |v| Time.parse v if v }
    # end
    #
    # some_object = SomeClass.new(attrs)
    # some_object.airing # Returns a new Airing, or nil if attrs didn't have key airing.
    #
    # Keys can either be strings or symbols, it doesnt matter. All keys are stringified when
    # the object is initialized.
    #
    module ValueObjectAttributesFromHash
      NO_VALUE = :no_value_given_as_fallback

      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def property(name, default: NO_VALUE, &block)
          define_method name do
            value = @attributes.fetch name.to_s do
              if default != NO_VALUE
                default
              else
                fail KeyError, "key not found: #{name.to_s}"
              end
            end
            value = block.call value if block
            value
          end
        end
      end

      def initialize(attributes)
        @attributes = ::EchoCommon::Utils::Hash.new(attributes)
        @attributes.stringify!
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
