module EchoCommon
  # Value object represents a time of day
  #
  # In other words a class representing time without date, nor time zone.
  class TimeOfDay
    VALID_HOUR = 0..23.freeze
    VALID_MIN_SEC = 0..59.freeze

    SEC_PER_MINUTE = 60.freeze
    SEC_PER_HOUR = (SEC_PER_MINUTE * 60).freeze
    SEC_PER_DAY = ((SEC_PER_HOUR * 24) - 1).freeze

    def self.load(string)
      return if string.nil?

      parts = string.split(':').map &:to_i
      new *parts
    end

    def self.from_time(time)
      case time
      when Time, DateTime
        new time.hour, time.min, time.sec
      else
        fail ArgumentError, "Expected either Time or DateTime. Got: #{time}."
      end
    end

    def self.from_second_of_day(seconds)
      fail ArgumentError, "Given more seconds than in one day" if seconds > SEC_PER_DAY

      hour =    seconds / SEC_PER_HOUR;   seconds = seconds % SEC_PER_HOUR
      minute =  seconds / SEC_PER_MINUTE; seconds = seconds % SEC_PER_MINUTE

      new hour, minute, seconds
    end

    def self.dump(time_of_day)
      return if time_of_day.nil?

      time_of_day.to_s
    end



    attr_reader :hour, :minute, :second
    alias min minute
    alias sec second

    def initialize(hour = 0, minute = 0, second = 0)
      fail ArgumentError, "Invalid hour #{hour}" unless VALID_HOUR.include? hour
      fail ArgumentError, "Invalid minute #{minute}" unless VALID_MIN_SEC.include? minute
      fail ArgumentError, "Invalid second #{second}" unless VALID_MIN_SEC.include? second

      @hour, @minute, @second = hour, minute, second
      freeze
    end


    def second_of_day
      (hour * 60 * 60) +
      (minute * 60) +
      second
    end

    def +(seconds)
      self.class.from_second_of_day [second_of_day + seconds, SEC_PER_DAY].min
    end

    def -(seconds)
      self.class.from_second_of_day [second_of_day - seconds, 0].max
    end


    def to_s
      [
        "%02d" % hour,
        "%02d" % minute,
        "%02d" % second
      ].join(':')
    end

    def inspect
      "<#{self.class.name} #{to_s}>"
    end


    def <=>(other)
      if other.respond_to? :second_of_day
        second_of_day <=> other.second_of_day
      end
    end

    def equal?(other)
      if other.respond_to? :second_of_day
        second_of_day == other.second_of_day
      else
        false
      end
    end
    alias eql? equal?
    alias == equal?

    def hash
      second_of_day.hash
    end
  end
end
