require 'spec_helper'
require 'echo_common/hanami/controllers/authentication'
require 'securerandom'

# rubocop:disable Metrics/BlockLength
describe EchoCommon::Hanami::Controllers::Authentication do
  class AuthenticationControllerTest
    def self.before(_args)
    end

    def self.after(_args)
    end

    include EchoCommon::Hanami::Controllers::Authentication

    attr_accessor :jwt
  end

  subject { AuthenticationControllerTest.new }

  let(:user_id) { SecureRandom.uuid }
  let(:user)    { { 'id' => user_id, 'locale' => 'en' } }
  let(:payload) { { 'data' => { 'authenticated' => true, 'user' => user } } }


  describe '#current_user_id' do
    it 'gets logged in user from jwt' do
      allow(subject).to receive(:jwt).with(anything).and_return(EchoCommon::Services::Jwt::Token.new([payload]))
      subject.send(:set_current_user_id, {})

      expect(subject.send(:current_user_id)).to eq user_id
    end

    it 'is nil if token has expired' do
      allow(subject).to receive(:jwt).with(anything).and_raise JWT::ExpiredSignature
      subject.send(:set_current_user_id, {})

      expect(subject.send(:current_user_id)).to be_nil
    end
  end

  describe '#authenticated?' do
    it 'is true when user and authenticated is set correctly' do
      allow(subject).to receive(:jwt).with(anything).and_return(EchoCommon::Services::Jwt::Token.new([payload]))
      subject.send(:set_current_user_id, {})

      expect(subject.send(:authenticated?, {})).to eq true
    end

    it 'is false if token does not contain user' do
      payload['data'].delete 'user'
      allow(subject).to receive(:jwt).with(anything).and_return(EchoCommon::Services::Jwt::Token.new([payload]))
      subject.send(:set_current_user_id, {})

      expect(subject.send(:authenticated?, {})).to eq false
    end

    it 'is false if token does not contain authenticated true' do
      payload['data'].delete 'authenticated'
      allow(subject).to receive(:jwt).with(anything).and_return(EchoCommon::Services::Jwt::Token.new([payload]))
      subject.send(:set_current_user_id, {})

      expect(subject.send(:authenticated?, {})).to eq false
    end

    it 'is false if token has expired' do
      allow(subject).to receive(:jwt).with(anything).and_raise JWT::ExpiredSignature
      subject.send(:set_current_user_id, {})

      expect(subject.send(:authenticated?, {})).to eq false
    end
  end

  describe '#current_user_locale' do
    it 'gets locale from jwt' do
      allow(subject).to receive(:jwt).with(anything).and_return(EchoCommon::Services::Jwt::Token.new([payload]))
      subject.send(:set_current_user_id, {})
      subject.send(:set_current_user_locale, {})

      expect(subject.send(:current_user_locale)).to eq 'en'
    end

    it 'is nil if token has expired' do
      allow(subject).to receive(:jwt).with(anything).and_raise JWT::DecodeError.new('Not enough or too many segments')
      subject.send(:set_current_user_id, {})
      subject.send(:set_current_user_locale, {})

      expect(subject.send(:current_user_locale)).to be_nil
    end
  end
end
