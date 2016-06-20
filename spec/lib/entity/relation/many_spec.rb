require 'spec_helper'
require 'echo_common/entity/relation/many'


module EchoCommon
  describe Entity::Relation::Many do
    class TestRelation < Entity::Relation::Many
    end

    let(:owner) { double :owner }
    let(:subject) { TestRelation.new owner }

    it "is empty to begin with" do
      expect(subject).to be_empty
    end

    it "can add objects" do
      obj = double
      subject << obj

      expect(subject).to_not be_empty
      expect(subject).to eq [obj]
    end
  end
end
