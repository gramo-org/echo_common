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
        client: self.class.client,
        query_alias: nil
      )
        @index = index
        @query_index = query_alias || index
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
              logger: config.logger(tag: "elasticsearch"),
              config: config[:elasticsearch]
            )
          end
        DOC
      end

      # deletes all indices.
      # does not require index and type to be configured on the service
      def self.delete_all_indices
        new.delete_all_indices
      end

      # creates all indices.
      # does not require index and type to be configured on the service
      def self.create_all_indices
        new.create_all_indices
      end

      # calls instance method put_alias.
      # does not require index and type to be configured on the service
      def self.put_alias(*args)
        new.put_alias(*args)
      end
    end
  end
end
