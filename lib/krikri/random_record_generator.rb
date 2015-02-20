module Krikri
  # Gets random records from the search index
  class RandomRecordGenerator

    def initialize
      @solr_repo = Blacklight::SolrRepository.new(Blacklight::Configuration.new)
    end

    # @return Krikri::SearchIndexDocument
    def record
      solr_params = { :id => "*:*",
                      :sort => "random_#{rand(9999)} desc",
                      :rows => 1 }
      query_result = @solr_repo.search(solr_params)
      solr_response = Blacklight::SolrResponse.new(query_result, solr_params)
      Krikri::SearchIndexDocument.new(solr_response.docs.first)
    end
  end
end
