module EchoCommon
  # Class representing a paginatable array
  #
  # As of writing it only keeps data like limit, offset and total,
  # but in the future it may be able to given a data set and apply
  # it's limit, offset to the array it has been given.
  #
  # In other words: Take inspiration from example:
  # https://github.com/amatsuda/kaminari/blob/master/lib/kaminari/models/array_extension.rb
  #
  class PaginatableArray < Array
    attr_reader :limit, :offset, :total

    def initialize(array, limit:, offset:, total:)
      @limit = limit
      @offset = offset
      @total = total

      super array
    end

    def to_a
      self
    end
    alias to_ary to_a
  end
end
