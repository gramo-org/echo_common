require 'echo_common'
require 'echo_common/error'

# Copy pasted from hanami/model gem because we removed Hanami::Model dependency.
# After migration is done we are going to replace Hanami::Entity with ValueObject but for now
# we going to keep current behaviour.
require 'hanami/utils/kernel'

module Hanami
  module Entity
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        attributes :id
      end
    end

    module ClassMethods
      def attributes(*attrs)
        @attributes ||= Set.new
        return get_attributes unless attrs.any?
        set_attributes attrs
      end

      def define_attr_accessor(attr)
        attr_accessor(attr)
      end

      def allowed_attribute_name?(name)
        !instance_methods.include?(name)
      end

      protected

      def get_attributes
        @attributes ||= Set.new
        if self.superclass.respond_to?(:attributes)
          @attributes + self.superclass.get_attributes
        else
          @attributes
        end
      end

      def set_attributes(*attrs)
        Hanami::Utils::Kernel.Array(attrs).each do |attr|
          if allowed_attribute_name?(attr)
            define_attr_accessor(attr)
            @attributes << attr
          end
        end
      end
    end

    def initialize(attributes = {})
      attributes.each do |k, v|
        setter = "#{ k }="
        public_send(setter, v) if respond_to?(setter)
      end
    end

    def ==(other)
      self.class == other.class &&
         self.id == other.id
    end

    def to_h
      Hash[attribute_names.map { |a| [a, read_attribute(a)] }]
    end

    def attribute_names
      self.class.attributes
    end

    def inspect
      attr_list = attribute_names.inject([]) do |res, name|
        res << "@#{name}=#{read_attribute(name).inspect}"
      end.join(' ')

      "#<#{self.class.name}:0x00#{(__id__ << 1).to_s(16)} #{attr_list}>"
    end

    alias_method :to_s, :inspect


    def update(attributes={})
      attributes.each do |attribute, value|
        public_send("#{attribute}=", value)
      end
    end

    private

    def read_attribute(attr_name)
      public_send(attr_name)
    end
  end
end

module EchoCommon

  class CreateOnlyAttributeError < EchoCommon::Error; end

  class Entity
    include Hanami::Entity

    def self.create_only_attributes(*attrs)
      attrs.each do |attr|
        self.attributes attr
        define_method "#{attr}=".to_sym do |val|
          if instance_variable_defined?("@#{attr}")
            raise CreateOnlyAttributeError.new "Illegal to set #{attr} more than once"
          end

          instance_variable_set "@#{attr}", val
        end
      end
    end

    def hash
      return super if id.nil?

      self.class.hash ^ id.hash
    end

    def ==(other)
      other.object_id == object_id || other.instance_of?(self.class) && !id.nil? && other.id == id
    end

    alias eql? ==
  end
end
