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
    def initialize(opts = {})
      endpoint = opts.delete(:endpoint)
      @opts = opts
      @client = OAI::Client.new(endpoint)
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
        Krikri::OriginalRecord.build(rec.header.identifier, rec.metadata.to_s)
      end
    end

    # TODO: normalize records; there will be differences in XML
    # for different requests
    def get_record(identifier, opts = {})
      opts[:identifier] = identifier
      opts = opts.merge(@opts)
      Krikri::OriginalRecord
        .build(identifier,
               client.get_record(opts).doc.to_s)
    end
  end
end
