require 'couchrest'
require 'mime/types'

module CouchRest
  class Streamer
    ##
    # CouchRest::Streamer relies on curl. Some CouchDB servers behind HTTPS
    # may have self-signed certificates, so we're adding the `--insecure`
    # parameter to ignore strict certificate checking. There is probably a
    # more elegant way to do this. If we *do* need to monkey patch this, it
    # probably should be done in Heidrun and not Krikri.
    #
    # Note that we'll probably have to do something similar for #get_record
    # requests: https://github.com/rest-client/rest-client/issues/288
    def initialize
      self.default_curl_opts = [
        '--silent',
        '--insecure',
        '--no-buffer',
        '--tcp-nodelay',
        '-H "Content-Type: application/json"'
      ].join(' ')
    end
  end
end

module Krikri::Harvesters
  ##
  # A harvester implementation for CouchDB
  class CouchdbHarvester
    include Krikri::Harvester
    attr_accessor :client

    ##
    # @param opts [Hash] options to pass through to client requests.
    #   If {:couchdb => :view} is not specified, it defaults to using the
    #   CouchDB `_all_docs` view.
    # @see CouchRest::Database
    # @see http://docs.couchdb.org/en/latest/api/database/bulk-api.html
    #   CouchDB _all_docs endpoint
    # @see http://docs.couchdb.org/en/latest/api/ddoc/views.html CouchDB views
    # @see #expected_opts
    def initialize(opts = {})
      super
      @opts = opts.fetch(:couchdb, view: '_all_docs')
      @opts[:view] ||= '_all_docs'
      @client = CouchRest.database(uri)
    end

    ##
    # Streams a response from a CouchDB view to yield identifiers.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 record ids:
    #
    #     record_ids.take(1000)
    #
    # @see CouchRest::Database#view
    # @see CouchRest::Streamer
    def record_ids(opts = {})
      view = opts[:view] || @opts[:view]
      Enumerator.new do |y|
        client.view(view, include_docs: false) do |row|
          y.yield row['key']
        end
      end.lazy
    end

    ##
    # Returns the total number of documents reported by a CouchDB view.
    def count(opts = {})
      view = opts[:view] || @opts[:view]
      client.view(view, limit: 0, include_docs: false)['total_rows']
    end

    ##
    # Streams a response from a CouchDB view to yield documents.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 records:
    #
    #     records.take(1000)
    # @see CouchRest::Database#view
    # @see CouchRest::Streamer
    def records(opts = {})
      view = opts[:view] || @opts[:view]
      Enumerator.new do |y|
        client.view(view, include_docs: true) do |row|
          y.yield @record_class.build(mint_id(row['key']),
                                      row['doc'].to_json,
                                      'application/json')
        end
      end.lazy
    end

    ##
    # Retrieves a specific document from CouchDB.
    def get_record(identifier)
      @record_class.build(mint_id(identifier),
                          client.get(identifier).to_json,
                          'application/json')
    end

    ##
    # @see Krikri::Harvester::expected_opts
    def self.expected_opts
      {
        key: :couchdb,
        opts: {
          view: { type: :string, required: false }
        }
      }
    end
  end
end
