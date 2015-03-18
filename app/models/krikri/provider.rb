module Krikri
  class Provider

    ##
    # Get the names of all providers in search index
    # @return Array of Blacklight::SolrResponse::Facets::FacetItem's
    def all
      query_params = { :rows => 0,
                       :id => '*:*',
                       'facet.field' => 'provider_id' }
      Krikri::SolrResponseBuilder.new(query_params).response.facets.first.items
    end

    ##
    # Find a provider from the search index.
    # @param String - id of a provider
    # @return Krikri::SearchIndexDocument
    def find(id)

    end

  end
end
