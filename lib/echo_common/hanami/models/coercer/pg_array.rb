require 'hanami/model/coercer'
require 'sequel'
require 'sequel/extensions/pg_array'

module EchoCommon
  module Hanami
    module Models
      module Coercer
        class PGArray < ::Hanami::Model::Coercer
          @@type = nil


          # Returns a type specific subclass of PGArray.
          # If the class is already defined returns it, otherwise
          # creates a new dynamic class for the given type.
          # The type is communicated to ::Sequel.pg_array
          #
          # Example:
          #
          # ::EchoCommon::Hanami::Models::Coercer::PGArray.for(:varchar)
          # => EchoCommon::Hanami::Models::Coercer::PGArray::Varchar
          #
          # ::EchoCommon::Hanami::Models::Coercer::PGArray.for(:integer)
          # => EchoCommon::Hanami::Models::Coercer::PGArray::Integer
          #
          def self.for(type)
            PGArray.const_get("#{type.to_s.capitalize}")
          rescue
            PGArray.const_set(
              "#{type.to_s.capitalize}",
              Class.new(PGArray) { @@type = type }
            )
          end

          def self.dump(value)
            ::Sequel.pg_array(value, @@type) rescue nil
          end

          def self.load(value)
            ::Kernel.Array(value) unless value.nil?
          end
        end
      end
    end
  end
end