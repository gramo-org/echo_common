require 'echo_common/error'

unless defined? ::Lotus::Mailer
  fail EchoCommon::Error, "Didn't find Lotus::Mailer"
end

module EchoCommon
  module RSpec
    module Helpers
      module LotusMailHelper
        def self.included(base)
          base.class_eval do
            after do
              ::Lotus::Mailer.deliveries.clear
            end
          end
        end
      end
    end
  end
end
