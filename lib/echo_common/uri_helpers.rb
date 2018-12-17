require 'cgi'
require 'uri'

module EchoCommon
  module UriHelpers

    def self.add_query_variables(uri, vars)
      vars ||= {}
      raise ArgumentError unless vars.is_a? Hash
      uri = URI(uri) unless uri.is_a? URI::Generic
      query = CGI.parse(uri.query || '')
      query.merge!(vars)
      uri.query = URI.encode_www_form(query) unless query.empty?
      uri
    end

  end
end
