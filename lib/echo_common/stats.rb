module EchoCommon
  class Stats
    def initialize(buffer_size: 1024)
      @buffer_size = buffer_size
      @counters = {}
      @time_series = {}
    end

    def increment(counter)
      counter = counter.to_sym
      @counters[counter] ||= 0
      @counters[counter] += 1
    end

    def add_to_time_series(series, value)
      series = series.to_sym
      @time_series[series] ||= RingBuffer.new @buffer_size
      @time_series[series] << value
    end

    def counter(name); @counters[name.to_sym]; end
    def time_series(name); @time_series[name.to_sym].to_a; end

    class RingBuffer
      def initialize(size)
        @size = size
        @buffer = Array.new @size
        @i = 0
        @full = false
      end

      def push(obj)
        @buffer[@i] = obj
        @i = (@i + 1) % @size
        unless full?
          @full = @i == 0
        end
        return self
      end
      alias :<< :push

      def to_a
        if full?
          @buffer.clone
        else
          @buffer.slice(0, @i)
        end
      end

      private

      def full?
        return @full
      end
    end
  end
end
