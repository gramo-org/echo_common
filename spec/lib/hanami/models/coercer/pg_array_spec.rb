require 'spec_helper'
require 'echo_common/hanami/models/coercer/pg_array'

describe EchoCommon::Hanami::Models::Coercer::PGArray do

  describe ".load" do
    it "loads an array" do
      array = ["foo", "bar"]
      expect(described_class.load(array)).to eq array
    end
  end

  describe ".dump" do
    it "dumps an array" do
      dump = described_class.dump(["foo", "bar"])
      expect(dump).to be_a ::Sequel::Postgres::PGArray
      expect(dump.to_a).to eq ["foo", "bar"]
    end
  end

  describe ".for" do
    it "creates a dynamic class for the type" do
      typed_coercer = described_class.for(:varchar)
      expect(typed_coercer).to be < EchoCommon::Hanami::Models::Coercer::PGArray
    end

    it "retrurns same class for multiple invocations" do
      expect(described_class.for(:varchar)).to eq(described_class.for(:varchar))
    end
  end
end
