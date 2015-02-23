module Krikri
  # Contrtructs a list of providers
  class ProviderList

    def initialize
      @index_querier = Krikri::IndexQuerier.new
      @default_params = { :rows => 10,
                          :id => '*:*',
                          'facet.field' => 'provider_name' }
    end

    ##
    # Get the names of all providers in search index
    # @return Array of Blacklight::SolrResponse::Facets::FacetItem's
    def provider_names
      @index_querier.search(@default_params).facets.first.items
    end
  end
end
