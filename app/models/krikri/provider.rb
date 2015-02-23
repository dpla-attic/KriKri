module Krikri
  # This models provider data from Marmotta.
  class Provider

    ##
    # @return [Array<Blacklight::SolrResponse::Facets::FacetItem>]
    def self.all
      query_params = { :rows => 0,
                       :id => '*:*',
                       'facet.field' => 'provider_id' }
      Krikri::SolrResponseBuilder.new(query_params).response.facets.first.items
    end

    ##
    # @param id [String]
    # @return [Hash]
    #   Sample @return: { "provider_id"=>"_:b12",
    #                     "provider_name"=>"The New York Public Library" }
    #
    # TODO: Get provider data from Marmotta rather than Solr
    def self.find(id)
      query_params = { :rows => 1,
                       :provider_id => id,
                       :fl => 'provider_id, provider_name' }
      Krikri::SolrResponseBuilder.new(query_params).response.docs.first
    end
  end
end
