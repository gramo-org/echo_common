module EchoCommon
  # Represents a duration as seconds. Contains class methods for
  # parsing several duration formats. Acts as a float with regards to
  # equality.
  class Duration

    # Partialy implements the ISO standard: It only understands the
    # time part (No years, months, or days).
    def self.from_iso_8601(str)
      return if str.nil? || str[0..1] != 'PT'

      seconds = 0
      rx = /
        (\d+\.?\d*)
        ([HMS])
      /x
      str.scan(rx) do |magnitude, unit|
        magnitude = magnitude.to_f
        factor = case unit
                 when 'H'
                   3600
                 when 'M'
                   60
                 when 'S'
                   1
                 end
        seconds += magnitude * factor
      end
      seconds
    end

    # [[HH:]MM:]SS
    def self.from_hms(str)
      return if str.nil?
      begin
        parts = str.split(':').map { |s| Float(s) }
      rescue ArgumentError
        return nil
      end
      return if parts.length.zero? || parts.length > 3
      from_parts(*parts)
    end

    # ---
    # hours = 1
    # minutes = 2
    # seconds = 3.4
    # Duration::from_parts(hours, minutes, seconds) # => 3723.4
    # Duration::from_parts(minutes, seconds)        # =>  123.4
    # Duration::from_parts(seconds)                 # =>    3.4
    # ---
    def self.from_parts(*parts)
      factor = 1
      parts.reverse.reduce(0) do |sum, i|
        tmp_factor = factor
        factor *= 60
        sum + i * tmp_factor
      end
    end

    def initialize(seconds)
      @seconds = seconds.to_f
    end

    def ==(other)
      to_f == other.to_f
    end

    def to_f
      @seconds
    end

    def to_i
      to_f.to_i
    end
  end
end
