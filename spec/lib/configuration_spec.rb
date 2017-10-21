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

  class TestConfig < EchoCommon::Configuration
    private

    def session_timeout_minutes
      fetch(:session_timeout_minutes, 60).to_i
    end
  end

  subject do
    TestConfig.new env
  end

  describe "#logger" do
    it "returns a logger" do
      expect(subject.logger).to be_a Logger
    end

    it "has log level set when initialized the config" do
      config = TestConfig.new({'LOG_LEVEL' => 'WARN'})
      expect(config.logger.level).to eq Logger::WARN
    end

    it "has log level set when getting a logger" do
      config = TestConfig.new({'LOG_LEVEL' => 'INFO'})
      expect(config.logger(level: 'WARN').level).to eq Logger::WARN
    end

    it "raises error if log level is not configured correctly" do
      config = TestConfig.new({'LOG_LEVEL' => 'FOO'})
      expect { config.logger }.to raise_error EchoCommon::Configuration::LogLevelNameError
    end

    it "logs with app name" do
      output = stub_stdout_constant do
        subject.logger(tag: "test").info("test logger")
      end

      expect(output).to match /app=test severity=INFO time=[\d\-: ]+ UTC message=test logger/

      output = stub_stdout_constant do
        subject.logger(tag: "echo").info("test logger, take two!")
      end

      expect(output).to match /app=echo severity=INFO time=[\d\-: ]+ UTC message=test logger, take two!/
    end

    it "logs request_id set on thread" do
      output = stub_stdout_constant do
        logger = subject.logger tag: "test"

        Thread.current[:echo_request_id] = "1234"

        logger.info("test logger")
      end

      expect(output).to match /app=test severity=INFO time=[\d\-: ]+ UTC request_id=1234 message=test logger/

      Thread.current[:echo_request_id] = nil
    end

    it "can be used with JSON log formatter" do
      formatter = Hanami::Logger::JSONFormatter.new
      formatter.extend EchoCommon::Logger::FormatterWithRequestId

      output = stub_stdout_constant do
        logger = subject.logger formatter: formatter
        Thread.current[:echo_request_id] = "1234"
        logger.info "hello"
      end

      json_logged_data = JSON.parse output
      
      expect(json_logged_data['app']).to eq 'Hanami'
      expect(json_logged_data['severity']).to eq 'INFO'
      expect(json_logged_data['request_id']).to eq '1234'
      expect(json_logged_data['message']).to eq 'hello'

      Thread.current[:echo_request_id] = nil
    end
  end
  
  describe "#key?" do
    it { expect(subject.key?('SMS_FROM')).to eq true }
    it { expect(subject.key?('sms_from')).to eq true }
    it { expect(subject.key?(:SMS_FROM)).to eq true }
    it { expect(subject.key?(:sms_from)).to eq true }
    
    it { expect(subject.key?(:logger)).to eq true }
    it { expect(subject.key?(:LOGGER)).to eq true }
    it { expect(subject.key?('logger')).to eq true }
    it { expect(subject.key?('LOGGER')).to eq true }
    
    it { expect(subject.key?(:foo)).to eq false }
    it { expect(subject.key?('BAR')).to eq false }
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
      config = TestConfig.new(env: {})

      expect(config[:session_timeout_minutes]).to eq 60
    end
  end  
end
