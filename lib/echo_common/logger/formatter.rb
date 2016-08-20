require 'hanami/logger'

module EchoCommon
  module Logger
    # Module to extend log formatters to include request_id if set on thread
    module FormatterWithRequestId
      def call(severity, time, progname, msg)
        request_id = Thread.current[:echo_request_id]

        if request_id
          msg = {
            request_id: request_id,
            message: msg
          }
        end

        super severity, time, progname, msg
      end
    end

    class Formatter < ::Hanami::Logger::Formatter
      include FormatterWithRequestId
    end
  end
end
