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
      # The set of record ids is all of the record IDs in the database minus
      # the IDs of CouchDB design documents.
      view_opts = {include_docs: false, stream: true}
      client.view(view, view_opts).keys.lazy.select do |k|
        !k.start_with?('_design')
      end
    end

    ##
    # Return the total number of documents reported by a CouchDB view.
    #
    # @param opts [Hash]  Analysand `#view' options
    # @return [Fixnum]
    #
    def count(opts = {})
      view = opts[:view] || @opts[:view]
      # The count that we want is the total documents in the database minus
      # CouchDB design documents.  Asking for the design documents will give us
      # the total count in addition to letting us determine the number of
      # design documents.
      v = client.view(view,
                      include_docs: false,
                      stream: false,
                      startkey: '_design',
                      endkey: '_design0')
      total = v.total_rows
      design_doc_count = v.keys.size
      total - design_doc_count
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
        view_opts = {include_docs: true, stream: false, limit: limit}
        rows_retrieved = 0
        total_rows = 0
        loop do
          v = client.view(view, view_opts)
          rows = v.rows
          total_rows = v.total_rows
          rows_retrieved += rows.size
          rows.each do |row|
            next if row['id'].start_with?('_design')
            e.yield @record_class.build(
              mint_id(row['doc']['_id']),
              row['doc'].to_json,
              'application/json'
            )
          end
          break if rows_retrieved == total_rows
          view_opts[:startkey] = rows.last['id'] + '0'
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
