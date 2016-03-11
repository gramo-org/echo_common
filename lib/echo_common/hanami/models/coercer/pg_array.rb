require 'hanami/model/coercer'
require 'sequel'
require 'sequel/extensions/pg_array'

module EchoCommon
  module Hanami
    module Models
      module Coercer
        class PGArray < ::Hanami::Model::Coercer
          @@type = nil

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
