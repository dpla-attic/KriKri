module Krikri
  # Queries the Search Index
  class IndexQuerier

    def initialize
      @repo = Blacklight::SolrRepository.new(Blacklight::Configuration.new)
    end

    ##
    # @param Hash
    # @return Blacklight::SolrResponse
    def search(query_params)
      query_result = @repo.search(query_params)
      Blacklight::SolrResponse.new(query_result, query_params)
    end
  end
end
