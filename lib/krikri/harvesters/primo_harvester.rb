module Krikri::Harvesters
  ##
  # A harvester implementation for Primo
  #
  # Accepts options passed as `:primo => opts`
  #
  # Options allowed are:
  #
  #   - bulk_size: The number of records to fetch from Primo per request
  #     (default: 500)
  #
  class PrimoHarvester
    include Krikri::Harvester

    SEAR_NS = 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    PRIMO_NS = 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'

    PrimoHarvestError = Class.new(StandardError)

    def initialize(opts = {})
      @opts = opts.fetch(:primo, {})
      super

      @opts[:bulk_size] ||= 500

      @http_conn = Faraday.new do |conn|
        conn.request :retry, :max => 3
        conn.response :follow_redirects, :limit => 5
        conn.response :logger, Rails.logger
        conn.adapter :net_http
      end
    end

    ##
    # @return [Integer] the number of records available for harvesting.
    def count
      response = @http_conn.get(uri, :indx => '1', :bulkSize => '1')

      unless response.status == 200
        raise PrimoHarvestError, "Couldn't get record count"
      end

      total_hits = Nokogiri::XML(response.body)
                   .xpath('//sear:DOCSET')
                   .first
                   .attr('TOTALHITS')

      Integer(total_hits)
    end

    ##
    # @return [Enumerator::Lazy] an enumerator of the records targeted by this
    #   harvester.
    def records
      bulk_size = @opts.fetch(:bulk_size)

      (1...count).step(bulk_size).lazy.flat_map do |offset|
        response = @http_conn.get(uri, :indx => offset, :bulkSize => bulk_size)

        unless response.status == 200
          raise PrimoHarvestError, "Record fetch from #{offset} to " \
                                   "#{offset + bulk_size} failed"
        end

        enumerate_records(response.body)
      end
    end

    ##
    # @param identifier [#to_s] the identifier of the record to get
    # @return [#to_s] the record
    def get_record(identifier)
      response = @http_conn.get(uri,
                                :indx => 1,
                                :bulkSize => 1,
                                :query => "rid,exact,#{identifier}")

      unless response.status == 200
        raise PrimoHarvestError, "Couldn't get record: #{identifier}"
      end

      enumerate_records(response.body).first
    end

    private

    ##
    # Extract a page's worth of records from a Primo XML search result.
    # @param xml [String] an XML document returned from a Primo search
    # @return [Array] an array of @record_class instances
    def enumerate_records(xml)
      doc = Nokogiri::XML(xml)
      doc.root.add_namespace_definition('nmbib', PRIMO_NS)
      doc.xpath('//sear:DOC').lazy.map do |record|
        identifier = record.xpath('./nmbib:PrimoNMBib/nmbib:record/' \
                                  'nmbib:control/nmbib:recordid')
                     .first.text

        record = record.dup
        record.add_namespace_definition('sear', SEAR_NS)

        @record_class.build(mint_id(identifier), record.to_xml)
      end
    end
  end
end
