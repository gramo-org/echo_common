require "spec_helper"
require "echo_common/state_machine/machine"

describe EchoCommon::StateMachine::Machine do
  class InitialStateSubject
    include EchoCommon::StateMachine::Machine

    attr_accessor :state
    event :go, from: "resting", to: "going"

    def initialize(state = "resting")
      @state = state
    end
  end
  
  class Subject
    include EchoCommon::StateMachine::Machine

    attr_accessor :state, :have_chair, :superman

    def initialize(state = "sitting")
      @state = state
      @have_chair = true
      @superman = false
    end

    def save!
    end

    def self.scope(*args)
    end

    def have_chair?
      !!@have_chair
    end

    def superman?
      !!@superman
    end

    event :run, from: ["standing", "walking"], to: "running"
    event :fly, from: "running", to: "flying", guard: -> { superman? }
    event :land, from: "flying", to: "standing", guard: ->(object) { object.superman? }
    event :walk, from: ["running", "standing"], to: "walking"
    event :stop, from: ["running", "walking"], to: "standing"
    event :sit, from: "standing", to: "sitting", guard: :have_chair?
    event :stand, from: "sitting", to: "standing"
  end

  it "has a predicate for initial state" do
    expect(InitialStateSubject.new).to be_resting
  end

  subject { Subject.new }

  context "When sitting" do
    it "can stand" do
      subject.stand!
      expect(subject.standing?).to be(true)
    end

    it "can't start running" do
      expect { subject.run! }.to raise_error(EchoCommon::StateMachine::Machine::StateTransitionError)
    end

    it "can't start walking" do
      expect { subject.walk! }.to raise_error(EchoCommon::StateMachine::Machine::StateTransitionError)
    end
  end

  context "When standing" do
    before { subject.stand! }

    it "can start walking" do
      subject.walk!
      expect(subject.walking?).to be(true)
    end

    it "returns true for can_walk?" do
      expect(subject.can_walk?).to be true
    end

    it "returns false for can_walk? when we are walking" do
      subject.walk!
      expect(subject.can_walk?).to be false
    end

    it "can start running" do
      subject.run!
      expect(subject.running?).to be(true)
    end

    it "can sit" do
      subject.sit!
      expect(subject).to be_sitting
    end

    it "can't sit if we don't have a chair" do
      subject.have_chair = false
      expect { subject.sit! }.to raise_error(EchoCommon::StateMachine::Machine::StateTransitionError)
    end
  end

  context "When running" do
    before do
      subject.stand!
      subject.run!
    end

    it "can start walking" do
      subject.walk!
      expect(subject.walking?).to be(true)
    end

    it "can stop" do
      subject.stop!
      expect(subject.standing?).to be(true)
    end

    it "can't sit down" do
      expect { subject.sit! }.to raise_error(EchoCommon::StateMachine::Machine::StateTransitionError)
    end

    it "can't fly" do
      expect { subject.fly! }.to raise_error(EchoCommon::StateMachine::Machine::StateTransitionError)
    end

    it "can fly and land when superman" do
      subject.superman = true

      subject.fly!
      expect(subject).to be_flying

      subject.land!
      expect(subject).to be_standing
    end
  end
end
