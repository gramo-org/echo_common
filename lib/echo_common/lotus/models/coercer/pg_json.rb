require 'lotus/model/coercer'
require 'sequel'

module EchoCommon
  module Lotus
    module Models
      module Coercer
        class PGJSON < ::Lotus::Model::Coercer
          def self.load(value)
            if value.is_a? String
              ::JSON.load value
            else
              value
            end
          end

          def self.dump(value)
            ::JSON.dump value.to_h
          end
        end
      end
    end
  end
end
