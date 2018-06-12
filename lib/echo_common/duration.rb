module EchoCommon
  # Represents a duration as seconds. Contains class methods for
  # parsing several duration formats. Acts as a float with regards to
  # equality.
  class Duration
    FACTORS = {
      'H' => 3600,
      'M' => 60,
      'S' => 1
    }.freeze

    # Partialy implements the ISO standard: It only understands the
    # time part (No years, months, or days).
    def self.from_iso_8601(str)
      return if str.nil? || str[0..1] != 'PT'

      seconds = 0
      rx = /
        (\d+\.?\d*)
        ([#{FACTORS.keys.join}])
      /x
      str.scan(rx) do |magnitude, unit|
        magnitude = magnitude.to_f
        factor = FACTORS.fetch unit
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

    # Returns an ISO 8601 representation of the duration.
    #
    # NOTE  We currently only represents the duration with hours, minutes and seconds. For
    #       playtime of recordings it should be enough.
    #
    # @return String
    def to_iso_8601
      return 'PT0S' if @seconds.zero?
      iso_units = units
      'PT' + iso_units
             .reject { |_unit, value| value.zero? } # Don't include zero values
             .to_a
             .map(&:reverse) # We want value before unit in our String
             .flatten
             .join
    end

    # Returns the duration as HH:MM:SS (zero padded)
    #
    # format - set this to :compact and all leading zeroes will be removed
    def to_hms(format)
      str = '%02d:%02d:%02d' % units.values
      str.sub!(/^[0:]{0,4}/, '') if format == :compat
      str
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

    private

    def units
      remainder_sec = @seconds.round # returns int
      units = {}

      FACTORS.each do |unit, factor|
        units[unit] = remainder_sec / factor
        remainder_sec = remainder_sec % factor
      end

      units
    end

  end
end
