require 'spec_helper'
require 'echo_common/lotus/models/coercer/pg_json'

describe EchoCommon::Lotus::Models::Coercer::PGJSON do
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
    it "dumps an object" do
      object = {foo: 'bar'}
      expect(described_class.dump(object)).to eq '{"foo":"bar"}'
    end
  end
end
