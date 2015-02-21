module Krikri::Harvesters
  ##
  # A harvester implementation for OAI-PMH
  class OAIHarvester
    include Krikri::Harvester
    attr_accessor :client

    ##
    # @param opts [Hash] options to pass through to client requests.
    #   Allowable options are specified in OAI::Const::Verbs. Currently :from,
    #   :until, :set, and :metadata_prefix.
    # @see OAI::Client
    # @see #expected_opts
    def initialize(opts = {})
      super
      @opts = opts.fetch(:oai, {})

      http_conn = Faraday.new do |conn|
        conn.request :retry, :max => 3
        conn.response :follow_redirects, :limit => 5
        conn.adapter :net_http
      end

      @client = OAI::Client.new(uri, :http => http_conn)
    end

    ##
    # Sends ListIdentifier requests lazily.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 record ids:
    #
    #     record_ids.take(1000)
    #
    def record_ids(opts = {})
      opts = opts.merge(@opts)
      client.list_identifiers(opts).full.lazy.flat_map(&:identifier)
    end

    # Count on record_ids will request all ids and load them into memory
    # TODO: an efficient implementation of count for OAI
    def count
      raise NotImplementedError
    end

    ##
    # Sends ListRecords requests lazily.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 records:
    #
    #     records.take(1000)
    #
    def records(opts = {})
      opts = opts.merge(@opts)
      client.list_records(opts).full.lazy.flat_map do |rec|
        @record_class.build(mint_id(rec.header.identifier),
                            record_xml(rec))

      end
    end

    ##
    # Gets a single record with the given identifier from the OAI endpoint
    #
    # @param identifier [#to_s] the identifier of the record to get
    # @param opts [Hash] options to pass to the OAI client
    def get_record(identifier, opts = {})
      opts[:identifier] = identifier
      opts = opts.merge(@opts)
      @record_class.build(mint_id(identifier),
                          record_xml(client.get_record(opts).record))
    end

    ##
    # Lists the sets available from the OAI endpoint. Accepts a block to
    # pass to `#map` on the resulting array.
    #
    # @example:
    #
    #   sets(&:spec)
    #
    # @param opts [Hash] options to pass to the OAI client
    # @return [Array<OAI::Set>] an array of sets.
    #
    # @see OAI::Set
    def sets(opts = {}, &block)
      arry = client.list_sets.full.to_a
      return arry unless block_given?
      arry.map(&block)
    end

    ##
    # @see Krikri::Harvester::expected_opts
    def self.expected_opts
      {
        key: :oai,
        opts: {
          set: {type: :string, required: false, multiple_ok: true},
          metadata_prefix: {type: :string, required: false},
          from: {type: :string, required: false},
          until: {type: :string, required: false}
        }
      }
    end

    private

    def record_xml(rec)
      doc = Nokogiri::XML::Builder.new do |xml|
        xml.record('xmlns' => 'http://www.openarchives.org/OAI/2.0/') {
          xml.header {
            xml.identifier rec.header.identifier
            xml.datestamp  rec.header.datestamp
            rec.header.set_spec.each do |set|
              xml.set_spec set.text
            end
          }
          xml << rec.metadata.to_s
          xml << rec.about.to_s unless rec.about.nil?
        }
      end
      doc.to_xml
    end
  end
end
