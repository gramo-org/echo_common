require 'echo_common/duration'

def do_test(expectations, against:)
  expectations.each do |i|
    it "converts '#{i[0].inspect}' to '#{i[1].inspect}'" do
      expect(described_class.public_send(against, i[0])).to eq i[1]
    end
  end
end

module EchoCommon
  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Style/ExtraSpacing
  describe Duration do
    describe "::from_iso_8601" do
      expectations = [
        # INPUT     | EXPECTED
        [nil,         nil],
        ["",          nil],
        ["ASFGSD",    nil],
        ["PT1M1S",     61],
        ["PT1M",       60],
        ["PT32S",      32],
        ["PT1H",     3600],
        ["PT2H2M2S", 7322],
      ]

      do_test expectations, against: :from_iso_8601
    end

    describe "::from_hms" do
      expectations = [
        # INPUT     | EXPECTED
        [nil,           nil],
        ["",            nil],
        ["ASFGSD",      nil],
        ["01",            1],
        ["34",           34],
        ["00:01",         1],
        ["01:00",        60],
        ["01:01",        61],
        ["03:34",       214],
        ["00:00:01",      1],
        ["00:01:00",     60],
        ["00:01:01",     61],
        ["00:03:34",    214],
        ["01:00:00",   3600],
        ["05:12:34", 18_754],

        ["34.5",       34.5],
        ["01:34.5",    94.5],
      ]

      do_test expectations, against: :from_hms
    end

    # ::from_parts implicitly tested by ::from_hms

    describe "#==" do
      context "::new(1)" do
        it do
          expect(described_class.new(1)).to eq 1.0
        end

        it do
          expect(described_class.new(1)).to eq 1
        end
      end
    end
  end
end
