require 'hanami/model/coercer'
require 'sequel'

module EchoCommon
  module Hanami
    module Models
      module Coercer
        class PGJSON < ::Hanami::Model::Coercer
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
