require 'database_cleaner'

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
