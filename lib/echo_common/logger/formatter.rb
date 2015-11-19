require 'lotus/logger'

module EchoCommon
  module Logger
    class Formatter < ::Lotus::Logger::Formatter
      def call(severity, time, progname, msg)
        request_id = Thread.current[:echo_request_id]

        if request_id
          progname = (progname.to_s + " [request_id=#{request_id}] ").lstrip
        end

        super severity, time, progname, msg
      end
    end
  end
end
