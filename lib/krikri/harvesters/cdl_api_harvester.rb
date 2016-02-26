module Krikri::Harvesters
  ##
  # An ApiHarvester implementation for the Califonia Digitial Library. 
  #
  # Expects Solr-like JSON responses/records.
  #
##
  class CdlApiHarvester < ApiHarvester
    include Krikri::Harvester
    attr_reader :opts

    ##
    # @param opts [Hash] options for the harvester
    # @see .expected_opts
    def initialize(opts = {})
      super
      # @todo should perform some validation of opts to ensure 
      #       what is being passed in meets the required fields 
      @opts = opts.fetch(:api, {})
    end

    ##
    # @return [Hash] A hash documenting the allowable options to pass to
    #   initializers.
    #
    # @see Krikri::Harvester::expected_opts
    def self.expected_opts
      {
        key: :api,
          opts: {
            headers: { 
              authentication: :string, required: true,
              params: { q: :string, required: true } 
            }
          }
      }
    end

    private

    ##
    # @param doc [#to_s] a raw record document with an identifier
    #
    # @return [String] the provider's identifier for the document
    def get_identifier(doc)
      doc['id']
    end

    ##
    # Send a request via `RestClient`, and parse the result as JSON
    def request(request_opts)
      JSON.parse(RestClient.get(uri, request_opts[:headers]))
    end

    ##
    # Given a current set of options and a number of records from the last
    # request, generate the options for the next request.
    #
    # @param opts [Hash] an options hash from the previous request
    # @param record_count [#to_i]
    #
    # @return [Hash] the next request's options hash
    def next_options(opts, record_count)
      old_start = opts[:headers][:params].fetch('start', 0)
      opts[:headers][:params][:start] = old_start.to_i + record_count
      opts
    end
  end
end