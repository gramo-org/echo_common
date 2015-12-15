require 'spec_helper'
require 'echo_common/utils/value_object_attributes_from_hash'

module EchoCommon::Utils
  describe ValueObjectAttributesFromHash do
    class TestValueObject
      include ValueObjectAttributesFromHash

      property(:number)
      property(:created_at) { |v| Time.parse v }
      property(:fallback, default: {})
      property(:no_value)
      property(:symbol_key)
    end

    subject do
      TestValueObject.new(
        "number" => "123",
        "created_at" => "2015-06-01 02:00:00 +0200",
        :symbol_key => "works-too!"
      )
    end

    it "has expected read methods" do
      expect(subject.number).to eq "123"
      expect(subject.created_at).to eq Time.parse "2015-06-01 02:00:00 +0200"
    end

    it "reads keys in hash which are symbols" do
      expect(subject.symbol_key).to eq "works-too!"
    end

    it "has a default value for fallback" do
      expect(subject.fallback).to eq({})
    end

    it "raises error if property has no value and no default" do
      expect { subject.no_value }.to raise_error KeyError
    end

    it "is equal to another object, with same values" do
      other = TestValueObject.new(
        "number" => "123",
        "created_at" => "2015-06-01 02:00:00 +0200",
        :symbol_key => "works-too!"
      )

      expect(subject).to eq other
    end
  end
end
