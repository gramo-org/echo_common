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
end
