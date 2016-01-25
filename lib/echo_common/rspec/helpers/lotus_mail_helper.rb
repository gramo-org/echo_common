require 'echo_common/error'

unless defined? ::Hanami::Mailer
  fail EchoCommon::Error, "Didn't find Hanami::Mailer"
end

module EchoCommon
  module RSpec
    module Helpers
      module HanamiMailHelper
        def self.included(base)
          base.class_eval do
            after do
              ::Hanami::Mailer.deliveries.clear
            end
          end
        end
      end
    end
  end
end
