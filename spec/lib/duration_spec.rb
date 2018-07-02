# rubocop:disable all

require 'echo_common/duration'

def do_test(expectations, against:)
  expectations.each do |i|
    it "converts '#{i[0].inspect}' to '#{i[1].inspect}'" do
      expect(described_class.public_send(against, i[0])).to eq i[1]
    end
  end
end

module EchoCommon
  describe Duration do
    @@iso_8601_expectations = [
      # INPUT     | EXPECTED
      [nil,             nil],
      ["",              nil],
      ["ASFGSD",        nil],
      ["PT1S",           1],
      ["PT0S",           0],
      ["PT1M1S",        61],
      ["PT1M",          60],
      ["PT32S",         32],
      ["PT1H",          3600],
      ["PT2H2M2S",      7322],
      ["P0DT0H4M4S",    244]
    ]

    describe "::from_iso_8601" do
      do_test @@iso_8601_expectations, against: :from_iso_8601
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

    describe "#to_hms" do
      context 'format full' do
        expectations = [
          # INPUT     | EXPECTED
          [    0,       '00:00:00'],
          [    1,       '00:00:01'],
          [  123,       '00:02:03'],
          [ 1230,       '00:20:30'],
          [12301,       '03:25:01'],
        ]

        expectations.each do |i|
          it "converts '#{i[0].inspect}' to '#{i[1].inspect}'" do
            expect(described_class.new(i[0]).to_hms).to eq i[1]
          end
        end
      end

      context 'format compact' do
        expectations = [
          # INPUT     | EXPECTED
          [    0,             '0'],
          [    1,             '1'],
          [  123,          '2:03'],
          [ 1230,         '20:30'],
          [12301,       '3:25:01'],
        ]

        expectations.each do |i|
          it "converts '#{i[0].inspect}' to '#{i[1].inspect}'" do
            expect(described_class.new(i[0]).to_hms(:compact)).to eq i[1]
          end
        end
      end

    end

    describe '#to_iso_8601' do
      @@iso_8601_expectations.each do |expectation|
        iso_value, sec = expectation
        next unless sec.is_a? Integer

        it "converts '#{sec}' to '#{iso_value}'" do
          expect(described_class.new(sec).to_iso_8601).to eq iso_value
        end
      end
    end

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
