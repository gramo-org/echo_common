module EchoCommon
  module TimeZone
    extend self

    def in_time_zone(zone)
      original_tz = ENV['TZ']
      ENV['TZ'] = zone

      yield
    ensure
      ENV['TZ'] = original_tz
    end
  end
end
