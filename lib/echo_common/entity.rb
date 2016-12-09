require 'hanami-model'
require 'hanami/utils/class_attribute'

require_relative 'utils/hashify'
require_relative 'error'

module EchoCommon
  class Entity < ::Hanami::Entity
    include Hanami::Utils::ClassAttribute

    def self.create_only_attributes(*)
      raise <<-TXT


        No longer supported. Schema on entity is frozen after definition.
        Entities by default are frozen. See class immutable,

        If we where to suppport this, Thorbjørn think it needs to make it's
        way in to hanami's attributes DSL.

        See:
          - https://github.com/hanami/model/blob/8775b815edfaef38a1d98cdd83704bbcf2c553f9/lib/hanami/entity.rb#L84-L87
          - https://github.com/hanami/model/blob/8775b815edfaef38a1d98cdd83704bbcf2c553f9/lib/hanami/entity/schema.rb#L139-L144

      TXT
    end

    class_attribute :immutable
    self.immutable = true

    def initialize(attributes = nil)
      return super if self.class.immutable

      @attributes = self.class.schema[attributes]
    end

    def method_missing(name, *args)
      return super if self.class.immutable

      if name.to_s.end_with? '='
        attr_name = name[0...-1]
        @attributes[attr_name.to_sym] = args[0]
      else
        super
      end
    end

    def respond_to_missing?(name, _include_all)
      return super if self.class.immutable

      attribute = name.to_s.end_with?('=') ? name[0...-1] : name
      attribute?(attribute) || super
    end


    # Serialize self in to a hash
    #
    # Hanami's default implementation does not serialize deep.
    # We do.
    #
    # @return Hash
    def to_h
      hash = super

      hash.keys.each do |attr_name|
        hash[attr_name] = Utils::Hashify[hash[attr_name]]
      end

      hash
    end
  end
end
