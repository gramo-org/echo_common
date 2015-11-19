fail "Requires ::Lotus::Model" unless defined?(::Lotus::Model)
fail "Requires ::Sequel" unless defined?(::Sequel)

require 'lotus/model/coercer'
require 'sequel'

module EchoCommon
  module Lotus
    module Models
      module Coercer
        class PGJSON < ::Lotus::Model::Coercer
          def self.load(value)
            value
          end

          def self.dump(value)
            ::JSON.dump value.to_h
          end
        end
      end
    end
  end
end
