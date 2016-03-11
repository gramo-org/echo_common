require 'hanami/model/coercer'
require 'sequel'
require 'sequel/extensions/pg_array'

module EchoCommon
  module Hanami
    module Models
      module Coercer
        class PGArray
          def self.for(type)
            new type
          end

          def initialize(type = nil)
            @type = type
          end

          def dump(value)
            ::Sequel.pg_array(value, @type) rescue nil
          end

          def load(value)
            ::Kernel.Array(value) unless value.nil?
          end
        end
      end
    end
  end
end
