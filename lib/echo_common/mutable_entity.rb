require 'hanami-model'

require_relative 'entity'

module EchoCommon
  # Represents an entity in our system
  #
  # This entity is mutable. It is not preferred to use this,
  # but as Echo has quite a few mutable entites this is here for
  # compatibility.
  class MutableEntity < Entity
    module SetterAttributeNameToAttributeName
      def self.call(attr_name)
        attr_name[0...-1].to_sym if attr_name.to_s.end_with? '='
      end
    end

    def initialize(attributes = nil)
      @attributes = self.class.schema[attributes]
    end

    def method_missing(name, *args)
      attr_name = SetterAttributeNameToAttributeName.call name

      if attr_name.nil? || !attribute?(attr_name)
        super
      else
        @attributes[attr_name.to_sym] = args[0]
      end
    end

    def respond_to_missing?(name, _include_all)
      attr_name = SetterAttributeNameToAttributeName.call name
      attr_name.nil? ? super : attribute?(attr_name)
    end
  end
end
