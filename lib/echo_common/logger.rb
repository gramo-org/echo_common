require 'lotus/logger'

module EchoCommon
  class Logger < ::Lotus::Logger

    def initialize(*)
      super
    end

    # Overrides ::Logger.add tagging message with request_id
    def add(*)
      request_id = Thread.current[:echo_request_id]
      if !!request_id
        self.progname = "[request_id=#{request_id}]"
      end

      super
    end

  end
end
