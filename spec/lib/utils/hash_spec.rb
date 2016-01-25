require 'spec_helper'
require 'echo_common/utils/hash'
require 'hanami/utils/hash'

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



      it "is a subclass of hanami hash" do
        expect(described_class.new).to be_a ::Hanami::Utils::Hash
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

      describe "#symbolize!" do
        let(:hash) do
          {
            "l" => ::Hanami::Utils::Hash.new({
              "hanami_key" => "value"
            }),
            "c" => ::EchoCommon::Utils::Hash.new({
              "echo_key" => "value"
            }),
            "h" => {"hash" => "value"}
          }
        end

        it "returns transformed object as expected" do
          transformed = described_class.new hash
          transformed.symbolize!

          expect(transformed[:l][:hanami_key]).to eq "value"
          expect(transformed[:c][:echo_key]).to eq "value"
          expect(transformed[:h][:hash]).to eq "value"
        end
      end

      describe "#stringify!" do
        let(:hash) do
          {
            l: ::Hanami::Utils::Hash.new({
              "hanami_key" => "value"
            }),
            c: ::EchoCommon::Utils::Hash.new({
              "echo_key" => "value"
            }),
            h: {"hash" => "value"}
          }
        end

        it "returns transformed object as expected" do
          transformed = described_class.new hash
          transformed.stringify!

          expect(transformed['l']['hanami_key']).to eq "value"
          expect(transformed['c']['echo_key']).to eq "value"
          expect(transformed['h']['hash']).to eq "value"
        end
      end
    end
  end
end
