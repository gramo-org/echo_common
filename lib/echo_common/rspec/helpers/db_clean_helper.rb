require 'database_cleaner'

# Make sure we run DatabaseCleaner only on test database
unless Echo.config[:sequel_adapter].url.include?('_test')
  raise "It's not a local DB!"
end

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

module EchoCommon
  module RSpec
    module Helpers
      module DbCleanHelper
        def self.included(base)
          base.class_eval do
            around(:each) do |example|
              DatabaseCleaner.strategy = if example.metadata[:omit_database_transaction]
                                           :truncation
                                         else
                                           :transaction
                                         end

              DatabaseCleaner.cleaning do
                example.run
              end
            end
          end
        end
      end
    end
  end
end
