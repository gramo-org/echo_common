require 'spec_helper'
require 'echo_common/utils/hash'

module EchoCommon
  module Utils
    describe Hash do
      let(:original_hash) do
        {
          my_hash: {
            "other-little" => "value"
          },
          my_array: [{has: "data"}]
        }
      end

      subject { described_class.new original_hash }



      it "is a subclass of lotus hash" do
        expect(described_class.new).to be_a ::Lotus::Utils::Hash
      end


      describe "#deep_transform_keys" do
        it "returns transformed object as expected" do
          transformed = subject.deep_transform_keys { |key| key.to_s.upcase }

          expect(transformed).to eq(
            "MY_HASH" => {"OTHER-LITTLE" => "value"},
            "MY_ARRAY" => [{"HAS" => "data"}]
          )
        end

        it "does not manipulate self" do
          transformed = subject.deep_transform_keys { |key| key.to_s.upcase }
          expect(subject).to eq original_hash
        end
      end

      describe "#deep_transform_keys!" do
        it "returns transformed object as expected" do
          subject.deep_transform_keys! { |key| key.to_s.upcase }

          expect(subject).to eq(
            "MY_HASH" => {"OTHER-LITTLE" => "value"},
            "MY_ARRAY" => [{"HAS" => "data"}]
          )
        end
      end
    end
  end
end
