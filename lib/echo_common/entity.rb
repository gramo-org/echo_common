require 'hanami-model'

module EchoCommon
  # Represents an entity in our system
  #
  # Entities are by default immutable.
  # If you need mutable entites, use MutableEntity
  class Entity < ::Hanami::Entity
  end
end
