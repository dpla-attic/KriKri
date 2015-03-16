module Krikri
  class Provider

    ##
    # Get the names of all providers in search index
    # @return Array of Blacklight::SolrResponse::Facets::FacetItem's
    def all
      index_querier = Krikri::IndexQuerier.new
      default_params = { :rows => 10,
                          :id => '*:*',
                          'facet.field' => 'provider_name' }
      index_querier.search(default_params).facets.first.items
    end

  end
end
