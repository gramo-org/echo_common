require 'hanami/model/coercer'
require 'sequel'
require 'sequel/extensions/pg_array'

module EchoCommon
  module Hanami
    module Models
      module Coercer
        class PGArray < ::Hanami::Model::Coercer
          def self.dump(value)
            ::Sequel.pg_array(value) rescue nil
          end

          def self.load(value)
            ::Kernel.Array(value) unless value.nil?
          end
        end
      end
    end
  end
end
