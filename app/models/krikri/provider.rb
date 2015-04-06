module Krikri
  ##
  # This models provider data from the {Krikri::Repository}.
  #
  # @todo create an appropriate `ActiveTriples::PersistenceStrategy' for
  #   handling providers as data from a repository alongside LDP data.
  # @see ActiveTriples::Resource
  class Provider < DPLA::MAP::Agent
    configure :base_uri => Krikri::Settings.prov.provider_base

    ##
    # Gives a list of all providers, ignoring those with no URI (bnodes).
    #
    # @return [Array<Krikri::Provider>]
    def self.all
      query_params = { :rows => 0,
                       :id => '*:*',
                       'facet.field' => 'provider_id' }
      response = Krikri::SolrResponseBuilder.new(query_params).response
      response.facets.first.items.map do |item|
        provider = new(item.value)
        provider.node? ? nil : provider
      end.compact
    end

    ##
    # @param id [#to_s] the identifier (local name or URI) of the provider
    #   to find
    #
    # @return [Krikri::Provider]
    # @todo Use {ActiveTriples}/{RDF::Repository} to populate the object
    def self.find(id)
      return nil if id.nil?
      provider = new(id)
      provider.reload
      return nil if provider.empty?
      provider
    end

    ##
    # Loads the provider's data from the repository.
    #
    # @return [Krikri::Provider] self
    def reload
      query = Krikri::Repository.query_client.select.distinct.where([self, :p, :o])
      query.each_solution do |solution|
        set_value(solution.p, solution.o)
      end

      self
    end

    ##
    # A list of records of type ore:Aggregation associated with this provider
    #
    # @return [Array<DPLA::MAP::Aggregation>] the Aggregations with this
    #   provider
    def records
      query = Krikri::Repository.query_client.select
              .where([:record, RDF::EDM.provider, self],
                     [:record, RDF.type, RDF::ORE.Aggregation])

      query.execute.map do |solution|
        DPLA::MAP::Aggregation.new(solution.record)
      end
    end

    ##
    # @return [String] the local name (last uri segment) for the provider
    def id
      node? ? nil : rdf_subject.to_s.gsub(base_uri.to_s, '')
    end

    ##
    # @return [String] the name of the provider
    def provider_name
      label.first || providedLabel.first || id
    end
  end
end
