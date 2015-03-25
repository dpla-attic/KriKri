module Krikri
  class SolrResponseBuilder
    attr_accessor :response
    ##
    # @param query_terms [Hash] of terms for a Solr query
    # Sample use:
    #   SolrResponseBuilder.new({ :q => 'dogs' }).response
    #   @return Blacklight::SolrResponse
    def initialize(query_params)
      self.response = Blacklight::SolrResponse.new(Blacklight::SolrRepository
        .new(Blacklight::Configuration.new).search(query_params), query_params)
    end
  end
end
