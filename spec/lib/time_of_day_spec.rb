require 'echo_common/time_of_day'

module EchoCommon
  describe TimeOfDay do
    describe ".load" do
      it "loads expected values" do
        expect(described_class.load("10:01:02")).to eq described_class.new(10, 1, 2)
        expect(described_class.load("00:01:02")).to eq described_class.new(0, 1, 2)
        expect(described_class.load("03:04:55")).to eq described_class.new(3, 4, 55)
      end

      it "fails on invalid string" do
        expect { described_class.load("a03:00:00") }.to raise_error ArgumentError
        expect { described_class.load("03:00:00:01") }.to raise_error ArgumentError
        expect { described_class.load("3.45") }.to raise_error ArgumentError
        expect { described_class.load("03;") }.to raise_error ArgumentError
      end

      it "loads a TimeOfDay" do
        expect(described_class.load(described_class.new(10, 1, 2))).to eq described_class.new(10, 1, 2)
      end

      it "loads nil" do
        expect(described_class.load(nil)).to eq nil
      end
    end

    describe ".from_time" do
      it "constructs from Time" do
        expect(described_class.from_time(Time.new 2002, 10, 31, 2, 3, 4)).to eq(
          described_class.new(2, 3, 4)
        )
      end

      it "constructs from DateTime" do
        expect(described_class.from_time(DateTime.new 2002, 10, 31, 2, 3, 4)).to eq(
          described_class.new(2, 3, 4)
        )
      end
    end

    describe ".from_second_of_day" do
      it "constructs correctly when seconds is within one day" do
        expect(described_class.from_second_of_day(1)).to eq described_class.new(0, 0, 1)
        expect(described_class.from_second_of_day(3660)).to eq described_class.new(1, 1, 0)
        expect(described_class.from_second_of_day(82800)).to eq described_class.new(23, 0, 0)
      end

      it "fails when given more seconds than in one day" do
        expect {
          described_class.from_second_of_day described_class::SEC_PER_DAY + 1
        }.to raise_error ArgumentError
      end
    end

    describe ".dump" do
      it "dumps to expected string" do
        expect(described_class.dump(described_class.new(10, 1, 02))).to eq "10:01:02"
        expect(described_class.dump(described_class.new(0, 1, 02))).to eq "00:01:02"
        expect(described_class.dump(described_class.new(3, 4, 55))).to eq "03:04:55"
      end

      it "dumps nil" do
        expect(described_class.dump(nil)).to eq nil
      end
    end


    subject { described_class.new 13, 2, 15 }

    it { expect(subject.hour).to eq 13 }
    it { expect(subject.minute).to eq 2 }
    it { expect(subject.second).to eq 15 }

    describe "#initialize" do
      it "fails on invalid values" do
        expect { described_class.new -1 }.to          raise_error ArgumentError
        expect { described_class.new 0, 60 }.to       raise_error ArgumentError
        expect { described_class.new 24 }.to          raise_error ArgumentError
        expect { described_class.new 23, 1, 102 }.to  raise_error ArgumentError
      end
    end

    describe "#second_of_day" do
      it "is 3600 when time is 01:00" do
        expect(described_class.new(1).second_of_day).to eq 3600
      end

      it "is 43200 when time is 12:01:01" do
        expect(described_class.new(12, 1, 1).second_of_day).to eq 43261
      end
    end

    describe "#strftime (#to_s)" do
      it "returns hour, minute and second" do
        expect(subject.strftime).to eq "13:02:15"
      end

      it "returns on format we ask for" do
        expect(subject.strftime "%H.%M").to eq "13.02"
        expect(subject.strftime "%H %M".freeze).to eq "13 02"
      end
    end

    describe "calculations" do
      it "adds seconds" do
        expect(subject + 10).to eq described_class.new(13, 2, 25)
        expect(subject - 5).to eq described_class.new(13, 2, 10)
      end

      it "adds no more than up to max a day" do
        expect(subject + 100000000).to eq described_class.new(23, 59, 59)
      end

      it "subtracts no more than down to 0" do
        expect(subject - 100000000).to eq described_class.new(0, 0, 0)
      end

      it "is changeable" do
        changed = subject.change(second: 59)
        expect(changed).to eq described_class.new(subject.hour, subject.minute, 59)
      end
    end


    describe "equality" do
      it "is considered equal when second_of_day is the same" do
        other = described_class.new 13, 2, 15

        expect(subject).to be_equal other
        expect(subject).to be_eql other
        expect(subject).to eq other
        expect(subject.hash).to eq other.hash
      end

      it "is not equal object of other type" do
        expect(subject == "foo").to eq false
      end
    end

    describe "comparable" do
      it "is comparable" do
        t1 = described_class.new 1, 2, 3
        t2 = described_class.new 1, 2, 4
        t3 = described_class.new 1, 3, 1
        t4 = described_class.new 2, 0, 0

        expect([t2, t1, t3, t4].sort).to eq [
          t1, t2, t3, t4
        ]
      end

      it "can be compared with >" do
        t1 = described_class.new 1
        t2 = described_class.new 2

        expect(t1 < t2).to eq true
      end

      it "can be compared with <" do
        t1 = described_class.new 1
        t2 = described_class.new 2

        expect(t1 > t2).to eq false
      end

      it "fails if you incomparable objects" do
        expect {
          subject < "foo"
        }.to raise_error ArgumentError
      end
    end

    describe "usage in range" do
      it "is determined to be included in a range" do
        expect(described_class.new(0)..described_class.new(2)).to include described_class.new(1)
        expect(described_class.new(1)..described_class.new(1, 1)).to include described_class.new(1, 0, 1)
        expect(described_class.new(1)..described_class.new(1, 1)).to_not include described_class.new(1, 1, 1)
      end
    end
  end
end
