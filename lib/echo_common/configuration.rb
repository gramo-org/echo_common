require 'echo_common/error'

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



    private

    def session_timeout_minutes
      fetch(:session_timeout_minutes) { 60 }.to_i
    end

    def bcrypt_cost
      fetch(:bcrypt_cost) { 10 }.to_i
    end

    def database_url
      if fetch(:snap_ci) { false }
        fetch :snap_db_pg_url
      else
        fetch :echo_database_url
      end
    end

    def force_ssl
      fetch(:force_ssl) { '' } == 'true'
    end

    def smtp
      {
        address: fetch('smtp_host'),
        port: fetch('smtp_port'),
        authentication: :plain,
        user_name: fetch('smtp_user'),
        password: fetch('smtp_pass'),
        domain: 'gramo.no',
        enable_starttls_auto: true
      }
    end

    def log_level
      fetch(:log_level).upcase
    end


    def fetch(key, &block)
      key = key.to_s.upcase
      @env.fetch key, &block
    rescue ::KeyError => error
      raise Configuration::KeyError, "'#{key}' was not found."
    end
  end
end
