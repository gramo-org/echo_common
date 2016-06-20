require 'forwardable'

module EchoCommon
  class Entity
    module Relation
      # Class representing a relation between one-to-many objects
      #
      # - It acts as an array, with minimal public API.
      # - It keeps it's @owner, which is the object owning all the objects in
      #   this relation.
      #
      # For more advanced relation operation, like filter relation based on time, date or
      # other state you can create a subclass and build upon #select and #reject.
      class Many
        extend Forwardable

        def_delegators :@collection,
          :<<, :delete,
          :each, :each_with_index, :map,
          :length, :first, :last, :[],
          :any?, :empty?, :include?,
          :==, :equal?, :eql?, :eq?, :hash

        def initialize(owner, collection = [])
          @owner = owner
          @collection = collection
        end


        private

        def select(&block)
          self.class.new @owner, @collection.select(&block)
        end

        def reject(&block)
          self.class.new @owner, @collection.reject(&block)
        end
      end
    end
  end
end
