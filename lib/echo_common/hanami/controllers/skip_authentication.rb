module EchoCommon
  module Hanami
    module Controllers
      #
      # Skips authentiction for controllers which have
      # authentication before callback set up.
      #
      # @see EchoCommon::Hanami::Controllers::Authentication
      #
      module SkipAuthentication
        def authenticate!
          # Do nothing
        end
      end
    end
  end
end
