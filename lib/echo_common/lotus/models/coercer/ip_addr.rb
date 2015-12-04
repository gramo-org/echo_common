require 'ipaddr'
require 'lotus/model/coercer'

module EchoCommon
  module Lotus
    module Models
      module Coercer
        class IPAddr < ::Lotus::Model::Coercer
          def self.load(value)
            ::IPAddr.new value unless value.nil?
          end

          def self.dump(value)
            value = value.to_s
            value.length > 0 ? value : nil
          end
        end
      end
    end
  end
end
