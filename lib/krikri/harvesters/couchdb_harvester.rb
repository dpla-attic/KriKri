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
      @opts[:limit] ||= 10
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
    # Makes requests to a CouchDB view to yield documents.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 records:
    #
    #     records.take(1000)
    #
    # Batches of records are requested, in order to avoid using
    # `Analysand::StreamingViewResponse`, and the CouchDB `startkey` parameter
    # is used for greater efficiency than `skip` in locating the next page of
    # records.
    #
    # @return [Enumerator]
    # @see Analysand::Viewing
    # @see http://docs.couchdb.org/en/latest/couchapp/views/collation.html#all-docs
    def records(opts = {})
      view = opts[:view] || @opts[:view]
      limit = opts[:limit] || @opts[:limit]

      en = Enumerator.new do |e|
        startkey = '0'
        view_opts = {include_docs: true, stream: false, limit: limit}
        loop do
          view_opts[:startkey] = startkey
          docs = client.view(view, view_opts).docs
          docs.each do |doc|
            e.yield @record_class.build(
              mint_id(doc['_id']), doc.to_json, 'application/json'
            )
          end
          break if docs.size < limit
          startkey = docs.last['_id'] + '0'
        end
      end
      en.lazy
    end

    ##
    # Retrieves a specific document from CouchDB.
    #
    # Uses Analysand::Database#get!, which raises an exception if the
    # document cannot be found.
    #
    # @see Analysand::Database#get!
    def get_record(identifier)
      doc = client.get!(CGI.escape(identifier)).body.to_json
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
