require 'spec_helper'
require 'echo_common/hanami/models/coercer/pg_json'

describe EchoCommon::Hanami::Models::Coercer::PGJSON do
  describe ".load" do
    it "loads an object" do
      object = {foo: 'bar'}
      expect(described_class.load(object)).to eq object
    end

    it "loads a string" do
      expect(described_class.load('{"foo":"bar"}')).to eq({"foo" => "bar"})
    end
  end

  describe ".dump" do
    it "dumps an array" do
      array = [1,2,3]
      expect(described_class.dump(array)).to eq '[1,2,3]'
    end

    it "dumps an object" do
      object = {foo: 'bar'}
      expect(described_class.dump(object)).to eq '{"foo":"bar"}'
    end
  end
end
