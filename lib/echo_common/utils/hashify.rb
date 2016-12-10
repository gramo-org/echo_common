require_relative '../entity'

module EchoCommon
  module Utils
    # Hashifies a given value
    module Hashify
      module_function

      def [](value)
        if value.respond_to? :to_hash
          value.to_hash
        elsif value.is_a? Entity
          value.to_h
        elsif value.respond_to? :map
          value.map { |item| self[item] }
        else
          value
        end
      end
    end
  end
end
