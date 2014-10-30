module Krikri::Harvesters
  ##
  # A harvester implementation for OAI-PMH
  class OAIHarvester < Krikri::Harvester
    attr_accessor :client

    def initialize(opts = {})
      endpoint = opts.delete(:endpoint)
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
    def record_ids
      client.list_identifiers.full.lazy.flat_map(&:identifier)
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
    def records
      client.list_records.full.lazy.flat_map do |rec|
        Krikri::OriginalRecord.new(rec.metadata.to_s)
      end
    end

    # TODO: normalize records; there will be differences in XML
    # for different requests
    def get_record(identifier)
      Krikri::OriginalRecord
        .new(client.get_record(:identifier => identifier).doc.to_s)
    end
  end
end
