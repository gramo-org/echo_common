require 'ipaddr'
require 'lotus/model/coercer'

module EchoCommon
  module Lotus
    module Models
      module Coercer
        class IPAddr < ::Lotus::Model::Coercer
          def self.load(value)
            ::IPAddr.new value
          end

          def self.dump(value)
            value.to_s
          end
        end
      end
    end
  end
end
