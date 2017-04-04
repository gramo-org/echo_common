require 'hanami/model/coercer'
require 'sequel'
require 'sequel/extensions/pg_array'

module EchoCommon
  module Hanami
    module Models
      module Coercer
        class PGArray < ::Hanami::Model::Coercer
          @type = nil

          class << self
            attr_accessor :type

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
            def for(type)
              PGArray.const_get(const_name(type))
            rescue
              PGArray.const_set(const_name(type), Class.new(PGArray) { @type = type })
            end

            def dump(value)
              ::Sequel.pg_array(value, @type) rescue nil
            end

            def load(value)
              ::Kernel.Array(value) unless value.nil?
            end

            # Makes const mapping able to handle values with spaces
            # e.g. :'timestamp without time zone' => :Timestamp_With_Time_Zone
            def const_name(type)
              type.to_s.split(' ').map(&:capitalize).join('_')
            end
          end
        end
      end
    end
  end
end
