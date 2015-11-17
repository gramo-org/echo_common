# encoding utf-8
require 'spec_helper'
require "echo_common/services/jwt"

describe EchoCommon::Services::Jwt do
  let(:config) do
    {
      jwt_alg: 'HS256',
      jwt_key: 'secret',
      jwt_key_pub: 'secret'
    }
  end

  it "creates signed token, which is decodeable" do
    data = { 'foo' => 'bar', 'name' => 'Thorbjørn' }

    token = described_class.encode data, config: config
    expect(token).not_to be_nil

    decoded = described_class.decode token, config: config
    expect(decoded.to_h).to eq data
  end

  it "fails on bogus data" do
    data = { 'foo' => 'bar', 'name' => 'Thorbjørn' }

    token = described_class.encode data, config: config

    expect {
      JWT.decode token, 'bogus', config[:jwt_alg]
    }.to raise_error(JWT::VerificationError)
  end
end
