require 'echo_common/error'

module EchoCommon
  module Elasticsearch
    # Restore a production snapshot takes longer than we are allowed to
    # have an open connection with the normal 'wait_for_completion' option.
    #
    # In order to wait for a restore to complete we need to dig in to recovery
    # status of our cluster.
    #
    # This class aids and exposes a user friendly API for waiting on the restore.
    class RestoreWaitOnCompletion

      # Create a new RestoreWaitOnCompletion instance
      #
      # @param      elasticsearch_client      Expecting ::Elasticsearch::Client.new
      # @param      retries                   How many retries should we do?
      # @param      wait_sec                  Seconds to wait between retries
      def initialize(elasticsearch_client, retries: 200, wait_sec: 30)
        @client = elasticsearch_client
        @retries = retries
        @wait_sec = wait_sec
      end

      def wait_for_completion
        loop do
          return if finished?

          raise 'No retries left' if (@retries -= 1).zero?

          sleep @wait_sec
        end
      end

      private

      def finished?
        statuses = @client.cat.recovery h: ['st'], format: 'json'

        statuses.all? { |s| s['st'] == 'done' }
      end
    end
  end
end