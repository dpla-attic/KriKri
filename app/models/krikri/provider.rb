module Krikri
  class Provider

    ##
    # Get the names of all providers in search index
    # @return Array of Blacklight::SolrResponse::Facets::FacetItem's
    def all
      index_querier = Krikri::IndexQuerier.new
      default_params = { :rows => 0,
                          :id => '*:*',
                          'facet.field' => 'provider_id' }
      index_querier.search(default_params).facets.first.items
    end

    ##
    # Find a provider from the search index.
    # @param String - id of a provider
    # @return Krikri::SearchIndexDocument
    def find(id)

    end

  end
end
