require 'spec_helper'
require 'echo_common/utils/value_object_attributes_from_hash'

module EchoCommon::Utils
  describe ValueObjectAttributesFromHash do
    class TestValueObject
      include ValueObjectAttributesFromHash

      property(:number)
      property(:created_at) { |v| Time.parse v }
    end

    subject do
      TestValueObject.new(
        "number" => "123",
        "created_at" => "2015-06-01 02:00:00 +0200"
      )
    end

    it "has expected read methods" do
      expect(subject.number).to eq "123"
      expect(subject.created_at).to eq Time.parse "2015-06-01 02:00:00 +0200"
    end

    it "is equal to another object, with same values" do
      other = TestValueObject.new(
        "number" => "123",
        "created_at" => "2015-06-01 02:00:00 +0200"
      )

      expect(subject).to eq other
    end
  end
end
