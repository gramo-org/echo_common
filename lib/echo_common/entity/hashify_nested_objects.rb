require_relative '../entity'
require_relative '../utils/hashify'

module EchoCommon
  class Entity < ::Hanami::Entity
    # Module to Hashify nested objects
    #
    # Hanami's default implementation does hashify nested objects.
    # This means that if you have an instance of Entyty Person with
    # an array of or a reference to Address entity and you call #to_h
    # on the person the Address will be included in the hash as the object,
    # not the Address' hash representation.
    #
    # Include this module in to Person and all of it's objects will be asked
    # to become a hash.
    #
    # NOTE Be aware of circular structure which will result in an endless loop
    #      if you include this in multiple entities which references each other
    module HashifyNestedObjects
      # Serialize self in to a hash
      #
      # @return Hash
      def to_h
        hash = super

        hash.keys.each do |attr_name|
          hash[attr_name] = Utils::Hashify[hash[attr_name]]
        end

        hash
      end

      alias to_hash to_h
    end
  end
end
