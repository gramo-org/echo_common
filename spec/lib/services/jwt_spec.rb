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

  describe ".create_session_token" do
    let(:user) do
      {
        id: "1"
      }
    end

    let(:exp) { Time.now.to_i + 60 * 5 }

    it "creates expected token" do
      token = described_class.create_session_token(user: user, exp: exp, config: config)
      decoded = described_class.decode token, config: config

      expect(decoded.to_h).to eq(
        "data" => {
          "authenticated" => true,
          "user" => {
            "id" => "1"
          }
        },
        "exp" => exp
      )
    end

    it "creates token with extra data" do
      token = described_class.create_session_token(
        data: {some: "data"}, user: user, exp: exp, config: config
      )
      decoded = described_class.decode token, config: config

      expect(decoded.to_h).to eq(
        "data" => {
          "some" => "data",
          "authenticated" => true,
          "user" => {
            "id" => "1"
          }
        },
        "exp" => exp
      )
    end
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
