require 'spec_helper'
require 'echo_common/roar/dasherize_properties'

describe EchoCommon::Roar::DasherizeProperties do
  class TestRoarDecorator
    prepend EchoCommon::Roar::DasherizeProperties

    attr_reader :received_args

    def to_hash(*args)
      @received_args = args

      {
        "playtime list" => 1,
        "foo_bar" => 2,
        :some_value => 3,
        :nested => {
          "nested_value" => 4
        }
      }
    end
  end

  it "dasherizes all properties" do
    hash = TestRoarDecorator.new.to_hash
    expect(hash).to eq(
      {
        "playtime-list" => 1,
        "foo-bar" => 2,
        "some-value" => 3,
        "nested" => {
          "nested-value" => 4
        }
      }
    )
  end

  it "receives some arguments" do
    decorator = TestRoarDecorator.new
    expect {
      decorator.to_hash(1, 2)
    }.to change(decorator, :received_args).to [1, 2]
  end
end
