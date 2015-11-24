require 'echo_common/stats'

module EchoCommon
  describe Stats do
    subject { Stats.new(buffer_size: 5) }

    describe "#increment" do
      it do
        subject.increment(:foo)
        subject.increment(:foo)
        expect(subject.counter :foo).to eq 2
      end
    end

    describe "#add_to_time_series" do
      it do
        subject.add_to_time_series(:foo, 1)
        expect(subject.time_series :foo).to eq [1]
      end

      it do
        (1..5) .each do |i|
          subject.add_to_time_series(:foo, i)
        end
        expect(subject.time_series :foo).to eq (1..5).to_a
      end

      it do
        (1..6) .each do |i|
          subject.add_to_time_series(:foo, i)
        end
        expect(subject.time_series :foo).to eq [6, 2, 3, 4, 5]
      end
    end
  end
end
