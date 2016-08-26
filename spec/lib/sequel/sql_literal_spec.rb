require 'spec_helper'
require 'echo_common/sequel/sql_literal'

module EchoCommon::Sequel
  describe SqlLiteral do
    class TestClass
      include SqlLiteral

      def initialize(string); @string = string; end
      def to_s; @string; end
    end

    let(:sql) { double :sequel_sql_object }

    it "returns object's #to_s quoted" do
      object = TestClass.new "some string"
      expect(object.sql_literal(sql)).to eq %Q{'some string'}
    end

    it "escapes single quote in value" do
      object = TestClass.new "some string'; SELECT * FROM users;"
      expect(object.sql_literal(sql)).to eq %Q{'some string''; SELECT * FROM users;'}
    end
  end
end
