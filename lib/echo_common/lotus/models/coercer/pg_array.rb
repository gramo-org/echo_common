fail "Requires ::Lotus::Model" unless defined?(::Lotus::Model)
fail "Requires ::Sequel" unless defined?(::Sequel)

require 'lotus/model/coercer'
require 'sequel'

module EchoCommon
  module Lotus
    module Models
      module Coercer
        class PGArray < ::Lotus::Model::Coercer
          def self.load(value)
            ::Kernel.Array value unless value.nil?
          end

          def self.dump(value)
            ::Sequel.pg_array value, :varchar
          end
        end
      end
    end
  end
end
