require 'forwardable'
require 'echo_common/error'

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
          :delete,
          :each, :each_with_index, :map,
          :length, :first,
          :any?, :empty?, :include?,
          :==, :equal?, :eql?, :hash

        class AlreadyAddedError < EchoCommon::Error
          attr_reader :object, :relation

          def initialize(object, relation)
            @object = object
            @relation = relation

            super "#{object} already added to #{relation}."
          end
        end

        def initialize(owner, collection = Set.new)
          @owner = owner
          @collection = collection
        end

        def push(object)
          raise AlreadyAddedError.new(object, self) if @collection.include? object
          @collection.add object

          self
        end
        alias_method :<<, :push

        def inspect
          "<#{self.class.name} owner: #{@owner.class.name}, length: #{length}>"
        end
        alias_method :to_s, :inspect

        def [](*args)
          @collection.to_a[*args]
        end

        def last(*args)
          @collection.to_a.last(*args)
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
