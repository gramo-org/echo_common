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
            value = case
                    when value.respond_to?(:to_ary)
                      value.to_ary
                    when value.respond_to?(:to_h)
                      value.to_h
                    else
                      raise ArgumentError.new "Argument 'value' needs to be an Array or to be convertible to an Hash with #to_h"
                    end
            ::JSON.dump value
          end
        end
      end
    end
  end
end
