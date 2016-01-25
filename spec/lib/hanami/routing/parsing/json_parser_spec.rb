require 'spec_helper'
require 'echo_common/hanami/routing/parsing/json_parser'

describe EchoCommon::Hanami::Routing::Parsing::VndJsonParseSupportAndBodyParseError do
  class TestClassJsonParser
    include EchoCommon::Hanami::Routing::Parsing::VndJsonParseSupportAndBodyParseError
  end

  subject { TestClassJsonParser.new }

  it "has correct mime types" do
    expect(subject.mime_types).to eq ['application/json', 'application/vnd.api+json']
  end

  it "fetches parse error and reraises it as a BodyParseError" do
    expect {
      subject.parse("{ foo")
    }.to raise_error EchoCommon::Hanami::Routing::Parsing::VndJsonParseSupportAndBodyParseError::BodyParseError
  end
end
