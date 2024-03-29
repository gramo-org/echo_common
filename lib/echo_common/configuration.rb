require 'echo_common/error'
require 'logger'

module EchoCommon
  # Echo Configuration
  #
  # Access application configuration. The public read interface is
  # equal to hash; it uses object[key] to read.
  #
  # You can inherit the Configuration class and override returned values
  # by defining methods equal to key name.
  #
  # class MyConfig < EchoCommon::Configuration
  #   private
  #
  #   # Returns bcrypt cost as integer, defaults to 10
  #   def bcrypt_cost
  #     fetch(:bcrypt_cost, 10).to_i
  #   end
  # end
  #
  # Example of usage:
  #
  #   config = EchoCommon::Configuration.new ENV  # or any hash like object
  #   config[:some_key]
  #
  class Configuration
    # Error raised if we are asked to #get a key which does not exist.
    class KeyError < EchoCommon::Error; end

    # Error raised when log leves is badly configured
    class LogLevelNameError < ::EchoCommon::Error; end

    def initialize(env)
      @env = env
    end

    # Returns value of configuration key
    #
    # Value is read from env, but may be read
    # through a private reader method when defined.
    def [](key)
      key = key.to_s.downcase

      if respond_to? key, true
        send key
      else
        fetch key
      end
    end

    def key?(key)
      return true if respond_to? key.to_s.downcase, true
      @env.key? key.to_s.upcase
    end

    def logger(tag: nil, level: self[:log_level])
      $test_logg ||= StringIO.new # rubocop:disable Style/GlobalVars

      logger = if ENV['HANAMI_ENV'] == 'test'
                 ::Logger.new($test_logg, level: level, progname: tag) # rubocop:disable Style/GlobalVars
               else
                 ::Logger.new(STDOUT, level: level, progname: tag)
               end
      logger.formatter = log_formatter

      logger
    rescue ArgumentError
      raise LogLevelNameError,
            "Log level '#{self[:log_level]}' does not exist. " \
            "Please ensure config 'LOG_LEVEL' is set correctly."
    end

    private

    def log_level
      fetch(:log_level, 'INFO').upcase
    end

    def log_formatter
      proc do |severity, datetime, progname, msg|
        request_id = Thread.current[:echo_request_id]
        formatter = ["app=#{progname}", "severity=#{severity}", "time=#{datetime.utc}"]
        formatter << "request_id=#{request_id}" if request_id
        formatter << "message=#{msg}"

        formatter.join(' ')
      end
    end

    # Fetches given key
    #
    # If no data for given key is found a default value may be provided, or a block,
    # just like Hash#fetch.
    #
    # nil isn't used as default value, as it would result in @env.fetch(key, nil) default to nil.
    def fetch(key, default = :no_value_was_provided_to_the_fetch_method, &block)
      key = key.to_s.upcase

      if default == :no_value_was_provided_to_the_fetch_method
        @env.fetch key, &block
      else
        @env.fetch key, default
      end
    rescue ::KeyError => error
      raise Configuration::KeyError, "'#{key}' was not found."
    end
  end
end
