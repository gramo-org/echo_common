require 'echo_common/time_zone'

module EchoCommon
  describe TimeZone do
    describe ".in_time_zone" do
      it "date.to_time creates time in correct time zone" do
        minsk = TimeZone.in_time_zone("Europe/Minsk") { Date.new(2015, 1, 15).to_time }
        oslo = TimeZone.in_time_zone("Europe/Oslo") { Date.new(2015, 1, 15).to_time }
        expect(minsk.utc + (60*60*2)).to eq oslo.utc
      end

      it "Time.parse creates time in correct time zone" do
        minsk = TimeZone.in_time_zone("Europe/Minsk") { Time.parse("2015-01-15 00:00:00") }
        oslo = TimeZone.in_time_zone("Europe/Oslo") { Time.parse("2015-01-15 00:00:00") }

        expect(minsk.utc + (60*60*2)).to eq oslo.utc
      end
    end
  end
end
