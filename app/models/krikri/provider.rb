module Krikri
  # This models provider data from Marmotta.
  class Provider < DPLA::MAP::Agent
    configure :base_uri => 'http://dp.la/api/contributor/'

    ##
    # @return [Array<Krikri::Provider>]
    def self.all
      query_params = { :rows => 0,
                       :id => '*:*',
                       'facet.field' => 'provider_id' }
      response = Krikri::SolrResponseBuilder.new(query_params).response
      response.facets.first.items.map { |item| new(item.value) }
    end

    ##
    # @param id [String] the identifier to find
    #
    # @return [Krikri::Provider]
    # @todo Use {ActiveTriples}/{RDF::Repository} to populate the object
    def self.find(id)
      provider = new(id)
      query = Krikri::Repository.query_client.select.where([provider, :p, :o])
      query.each_solution do |solution|
        provider.set_value(solution.p, solution.o)
      end
      provider
    end

    ##
    # @return [String] the name of the provider
    def provider_name
      label.empty? ? providedLabel.first : label.first
    end
  end
end
