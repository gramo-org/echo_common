require 'spec_helper'
require "echo_common/configuration"

describe "Echo configuration" do
  let(:env) do
    {
      'SESSION_TIMEOUT_MINUTES' => "120",
      'MAX_THREADS' => "8",
      'SMS_FROM' => "Gramo"
    }
  end

  subject do
    EchoCommon::Configuration.new env
  end

  describe "getting configuration" do
    it "reads given a symbol" do
      expect(subject[:max_threads]).to eq "8"
    end

    it "reads given a string" do
      expect(subject['max_threads']).to eq "8"
    end

    it "raises an error when given key isn't found" do
      expect {
        subject[:not_set]
      }.to raise_error EchoCommon::Configuration::KeyError
    end

    it "reads and casts some values" do
      expect(subject[:session_timeout_minutes]).to eq 120
    end

    it "reads and casts some values, key given as upcased string" do
      expect(subject['SESSION_TIMEOUT_MINUTES']).to eq 120
    end

    it "can provide defaults not included in given env" do
      config = EchoCommon::Configuration.new(env: {})

      expect(config[:session_timeout_minutes]).to eq 60
    end
  end
end
