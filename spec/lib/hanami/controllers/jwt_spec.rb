require 'spec_helper'
require 'echo_common/hanami/controllers/jwt'

describe EchoCommon::Hanami::Controllers::Jwt do
  let(:config) do
    {
      jwt_alg: 'HS256',
      jwt_key: 'secret',
      jwt_key_pub: 'secret'
    }
  end

  class JwtControllerTest
    include EchoCommon::Hanami::Controllers::Jwt

    def self.handle_exception(*args)
    end

    attr_accessor :params

    def halt(*args)
      @halt_was_ran = true
    end

    def halted?
      !!@halt_was_ran
    end
  end

  subject do
    JwtControllerTest.new.tap do |controller|
      controller.params = double(
        'env' => {},
        'raw' => {}
      )
    end
  end

  around do |example|
    EchoCommon::Services::Jwt.default_config = config
    example.run
    EchoCommon::Services::Jwt.default_config = nil
  end

  it "exposes jwt payload from request header" do
    payload = { 'data' => { 'foo' => 'bar' } }
    token = subject.encode_as_jwt payload
    subject.params.env.merge!('HTTP_AUTHORIZATION' => "Bearer #{token}")
    expect(subject.jwt.to_h).to eq payload
  end

  it "exposes jwt payload from query param" do
    payload = { 'data' => { 'foo' => 'bar' } }
    token = subject.encode_as_jwt payload

    expect(subject.params).to receive(:raw).and_return token: token
    expect(subject.jwt.to_h).to eq payload
  end

  it "raises error on ExpiredSignature" do
    payload = { 'data' => { 'foo' => 'bar' }, 'exp' => (Time.now.to_i - 5) }
    expired_token = subject.encode_as_jwt payload
    subject.params.env.merge!('HTTP_AUTHORIZATION' => "Bearer #{expired_token}")
    expect { subject.jwt }.to raise_error JWT::ExpiredSignature
  end
end
