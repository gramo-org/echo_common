require 'echo_common/entity'

module EchoCommon

  class AnEntity < Entity
    create_only_attributes :foo
    create_only_attributes :bar, :zap
  end

  describe AnEntity do
    describe "::create_only_attributes" do

      context "A fully created object" do

        subject {described_class.new foo: "foo", bar: "bar", zap: "zap"}

        %w(foo bar zap).each do |attr|
          it "has a attribute called #{attr}" do
            expect(subject.send attr).to eq attr
          end

          it "includes #{attr} in inspect" do
            expect(subject.inspect).to include "@#{attr}=\"#{attr}\""
          end
        end

        it "raises exception when trying to update an attribute" do
          expect {subject.foo="FOO"}.to raise_error CreateOnlyAttributeError
        end

        it "raieses an error when trying to set an attribute to nil" do
          expect {subject.foo=nil}.to raise_error CreateOnlyAttributeError
        end
      end

      context "An empty object" do
        %w(foo bar zap).each do |attr|
          it "has a attribute called #{attr}, that are undefined" do
            expect(subject.send attr).to eq nil
          end
        end

        it "raises exception when trying to update an attribute" do
          expect {subject.foo="FOO"}.not_to raise_error
        end

        it "raieses an error when trying to set an attribute to nil" do
          expect {subject.foo=nil}.not_to raise_error
        end
      end
    end
  end
end
