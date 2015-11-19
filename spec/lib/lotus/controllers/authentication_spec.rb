require 'spec_helper'
require 'echo_common/lotus/controllers/authentication'
require 'securerandom'

describe EchoCommon::Lotus::Controllers::Authentication do
  class AuthenticationControllerTest
    def self.before(args)
    end

    include EchoCommon::Lotus::Controllers::Authentication

    attr_accessor :jwt
  end

  subject { AuthenticationControllerTest.new }

  it "gets logged in user from jwt" do
    user = { 'id' => SecureRandom.uuid }
    subject.jwt = EchoCommon::Services::Jwt::Token.new [{ 'data' => { 'user' => user }}]

    expect(subject.send(:current_user_id)).to eq subject.jwt.get('data.user.id')
  end

  it "gets a falsy value for current_user_id if jwt does not contain user" do
    subject.jwt = EchoCommon::Services::Jwt::Token.new [{ 'data' => { 'foo' => 'bar' }}]

    expect(subject.send(:authenticated?)).to be_falsey
  end
end
