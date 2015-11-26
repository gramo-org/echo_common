require "lotus/utils/string"
require "lotus/utils/hash"

module EchoCommon
  module Roar
    # Module to be prepended to a Roar Representers to ensure all keys
    # are dasherized.
    module DasherizeProperties
      def to_hash(*args)
        HashWithDasherizeSupport.new(super).dasherize!
      end


      private

      class HashWithDasherizeSupport < ::Lotus::Utils::Hash
        def dasherize!
          keys.each do |k|
            v = delete(k)
            v = HashWithDasherizeSupport.new(v).dasherize! if v.is_a?(::Hash)

            self[::Lotus::Utils::String.new(k).dasherize.to_s] = v
          end

          self
        end
      end
    end
  end
end
