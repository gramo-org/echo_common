require 'spec_helper'
require 'echo_common/lotus/models/coercer/ip_addr'

describe EchoCommon::Lotus::Models::Coercer::IPAddr do
  let(:ip) { "127.0.0.1" }

  describe ".load" do
    it "creates an IPAddr representing the value" do
      expect(described_class.load(ip)).to eq ::IPAddr.new ip
    end

    it "returns nil if value is nil" do
      expect(described_class.load(nil)).to be_nil
    end
  end

  describe ".dump" do
    it "dumps it as a string" do
      expect(described_class.dump(::IPAddr.new ip)).to eq ip
    end

    it "dumps empty string to nil" do
      expect(described_class.dump('')).to be_nil
    end
  end
end