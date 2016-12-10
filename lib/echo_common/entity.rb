require 'hanami-model'

module EchoCommon
  # Represents an entity in our system
  #
  # Entities are by default immutable.
  # If you need mutable entites, use MutableEntity
  class Entity < ::Hanami::Entity
    # Don't want the entity to be counted as a hash by exposing implicit
    # conversion method.
    #
    # This leads to issues with for instance entity
    # being casted to hash if it is part of a hash and we use Hanami::Utils::Hash
    # Ex: Calling symbolize on this data structure: {foo: Entity.new(attr: 1)}
    # returns {foo: {attr: 1}}. I don't think we want that, and it also creates
    # issue where we have an entity like this:
    #
    # class TestRelease < MutableEntity
    #   attributes do
    #     attribute :year, Types::Strict::Int
    #   end
    # end
    #
    # class TestBook < MutableEntity
    #   include Entity::HashifyNestedObjects
    #
    #   attributes do
    #     attribute :main_release,  Types::Schema::CoercibleType.new(TestRelease)
    #   end
    # end
    #
    # release = TestRelease.new year: 2000
    # book = TestBook.new main_release: release
    #
    # book.release # returns { year: 2000 } as Hanami symbolizes hash structure
    #              # after dry-types has handled attributes according to schema.
    undef_method :to_hash
  end
end
