require 'analysand'

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
    # @see Analysand::Database
    # @see http://docs.couchdb.org/en/latest/api/database/bulk-api.html
    #   CouchDB _all_docs endpoint
    # @see http://docs.couchdb.org/en/latest/api/ddoc/views.html CouchDB views
    # @see #expected_opts
    def initialize(opts = {})
      super
      @opts = opts.fetch(:couchdb, view: '_all_docs')
      @opts[:view] ||= '_all_docs'
      @client = Analysand::Database.new(uri)
    end

    ##
    # Streams a response from a CouchDB view to yield identifiers.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 record ids:
    #
    #     record_ids.take(1000)
    #
    # @see Analysand::Viewing
    # @see Analysand::StreamingViewResponse
    def record_ids(opts = {})
      view = opts[:view] || @opts[:view]
      client.view(view, include_docs: false, stream: true).keys.lazy
    end

    ##
    # Returns the total number of documents reported by a CouchDB view.
    def count(opts = {})
      view = opts[:view] || @opts[:view]
      client.view(view,
                  limit: 0,
                  include_docs: false,
                  stream: true).total_rows
    end

    ##
    # Streams a response from a CouchDB view to yield documents.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 records:
    #
    #     records.take(1000)
    #
    # @see Analysand::Viewing
    # @see Analysand::StreamingViewResponse
    def records(opts = {})
      view = opts[:view] || @opts[:view]
      client.view(view, include_docs: true, stream: true).docs.lazy.map do |r|
        @record_class.build(mint_id(r['_id']), r.to_json, 'application/json')
      end
    end

    ##
    # Retrieves a specific document from CouchDB.
    #
    # Currently, this implementation does not use Analysand::Database#get
    # because of an issue where document IDs sent to that method are not
    # properly escaped.
    #
    # @see Analysand::Viewing
    # @see Analysand::StreamingViewResponse
    # @see Analysand::Database#get
    def get_record(identifier, opts = {})
      view = opts[:view] || @opts[:view]
      doc = client.view(view,
                        key: identifier,
                        include_docs: true,
                        stream: true).docs.first.to_json
      @record_class.build(mint_id(identifier), doc, 'application/json')
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
