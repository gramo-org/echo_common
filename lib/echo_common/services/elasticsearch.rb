require_relative 'elasticsearch/operations/index'
require_relative 'elasticsearch/operations/crud'
require_relative 'elasticsearch/operations/query'
require_relative 'elasticsearch/client'

module EchoCommon
  module Services
    class Elasticsearch
      include Operations::Index
      include Operations::Crud
      include Operations::Query

      def initialize(
        index: nil,
        type: nil,
        client: self.class.client
      )
        @index = index
        @type = type
        @client = client
      end

      def self.client=(client)
        @@client = client
      end

      def self.client
        @@client ||= new_client
      end

      def self.new_client
        raise <<-DOC
          You need to implement this method.

          For example:

          def self.new_client
            #{Client}.new(
              logger: Echo.config.logger(tag: "elasticsearch"),
              config: Echo.config[:elasticsearch]
            )
          end
        DOC
      end
    end
  end
end
