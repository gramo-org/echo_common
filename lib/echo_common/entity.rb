require 'hanami-model'

require_relative 'utils/hashify'

module EchoCommon
  # Represents an entity in our system
  #
  # Entities are by default immutable.
  # If you need mutable entites, use MutableEntity
  class Entity < ::Hanami::Entity
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
