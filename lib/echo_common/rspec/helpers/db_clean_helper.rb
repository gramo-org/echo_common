require 'database_cleaner'

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

module EchoCommon
  module RSpec
    module Helpers
      module DbCleanHelper
        def self.included(base)
          base.class_eval do
            let(:disable_db_clean) { false }

            before do
              unless disable_db_clean
                DatabaseCleaner.start
              end
            end

            after do
              unless disable_db_clean
                DatabaseCleaner.clean
              end
            end
          end
        end
      end
    end
  end
end
