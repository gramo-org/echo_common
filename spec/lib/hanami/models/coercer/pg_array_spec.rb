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

    it 'supports date' do
      typed_coercer = described_class.for(:date)
      expect(typed_coercer).to be < EchoCommon::Hanami::Models::Coercer::PGArray
    end

    it 'supports spaces in the type name' do
      expect(described_class.for(:'timestamp with time zone')).to be(
        EchoCommon::Hanami::Models::Coercer::PGArray::Timestamp_With_Time_Zone
      )
    end

    it 'returns correct type for class' do
      expect(described_class.for(:varchar).type).to eq(:varchar)
      expect(described_class.for(:'timestamp with time zone').type).to eq(:'timestamp with time zone')
      expect(described_class.for(:varchar).type).to eq(:varchar)
    end
  end
end
