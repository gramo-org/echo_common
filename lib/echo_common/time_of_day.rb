require 'date'

module EchoCommon
  # Value object represents a time of day
  #
  # In other words a class representing time without date, nor time zone.
  class TimeOfDay
    include Comparable

    VALID_HOUR = 0..23.freeze
    VALID_MIN_SEC = 0..59.freeze

    SEC_PER_MINUTE = 60.freeze
    SEC_PER_HOUR = (SEC_PER_MINUTE * 60).freeze
    SEC_PER_DAY = ((SEC_PER_HOUR * 24) - 1).freeze

    # Loads from string, separated by ':'
    #
    # Ex. "10:01:12"
    def self.load(object)
      return if object.nil?

      case object
      when TimeOfDay
        object
      when Time, DateTime
        from_time object
      when String
        parsed = try_parse_xmlschema object
        return load parsed if parsed

        parts = object.split(':')

        if parts.length < 1 || parts.length > 3 || parts.any? { |part| !part.match /\A\d{1,2}\Z/ }
          fail ArgumentError,
               "Invalid string ('#{object}') given. Must be like HH:MM:SS. MM and SS is optional."
        end

        new *parts.map(&:to_i)
      else
        fail ArgumentError, "Unable to load #{object}."
      end
    end

    # Checks if given object seems to be a valid object we can .load()
    def self.valid?(object)
      !!load(object)
    rescue ArgumentError
      false
    end

    # Creates from Ruby's Time or DateTime object
    def self.from_time(time)
      case time
      when Time, DateTime
        new time.hour, time.min, time.sec
      else
        fail ArgumentError, "Expected either Time or DateTime. Got: #{time}."
      end
    end

    # Creates from seconds
    #
    # Ex. from_second_of_day(3600) => TimeOfDay.new(1, 0, 0)
    def self.from_second_of_day(seconds)
      fail ArgumentError, "Given more seconds than in one day" if seconds > SEC_PER_DAY

      hour =    seconds / SEC_PER_HOUR;   seconds = seconds % SEC_PER_HOUR
      minute =  seconds / SEC_PER_MINUTE; seconds = seconds % SEC_PER_MINUTE

      new hour, minute, seconds
    end

    def self.try_parse_xmlschema(string)
      DateTime.xmlschema string
    rescue ArgumentError
      nil
    end

    # Dumps a time_of_day to string
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

    # Second of day this object represents
    #
    # Ex. new(1, 0, 1).second_of_day => 3601
    def second_of_day
      (hour * SEC_PER_HOUR) +
      (minute * SEC_PER_MINUTE) +
      second
    end

    # Adds seconds from this time
    #
    # Returns a new object.
    def +(seconds)
      self.class.from_second_of_day [second_of_day + seconds, SEC_PER_DAY].min
    end

    # Subtracts seconds to this time
    #
    # Returns a new object.
    def -(seconds)
      self.class.from_second_of_day [second_of_day - seconds, 0].max
    end

    # Changes given attribute(s)
    #
    # Returns a new object.
    def change(hour: nil, minute: nil, second: nil)
      self.class.new(
        hour    || self.hour,
        minute  || self.minute,
        second  || self.second,
      )
    end

    # Gives the next succ to this time
    #
    # Adds 1 second.
    def next
      self + 1
    end
    alias succ next

    def strftime(format = "%H:%M:%S")
      template = format.dup

      values = {
        hour:   "%02d" % hour,
        minute: "%02d" % minute,
        second: "%02d" % second
      }

      template.gsub!("%H", "%{hour}")
      template.gsub!("%M", "%{minute}")
      template.gsub!("%S", "%{second}")

      template % values
    end
    alias to_s strftime

    def inspect
      "<#{self.class.name} #{to_s}>"
    end


    def <=>(other)
      second_of_day <=> other.second_of_day
    rescue NoMethodError => error
      fail ArgumentError, "comparison of #{other.class} with #{inspect} failed"
    end

    def equal?(other)
      second_of_day == other.second_of_day
    rescue NoMethodError => error
      false
    end
    alias eql? equal?
    alias == equal?

    def hash
      second_of_day.hash
    end
  end
end
