module Krikri
  # Gets random records from the search index
  class RandomRecordGenerator
    include Krikri::QaProviderFilter

    def initialize
      @index_querier = Krikri::IndexQuerier.new
      @default_query_params = { :id => '*:*',
                                :sort => "random_#{rand(9999)} desc",
                                :rows => 1 }
    end

    # @return Krikri::SearchIndexDocument
    def record
      random_document(@default_query_params)
    end

    ##
    # @param String
    # @return Krikri::SearchIndexDocument
    def record_by_provider(provider)
      query_params = @default_query_params.merge(:fq => provider_fq(provider))
      random_document(query_params)
    end

    private

    ##
    # @param Hash
    # @return SearchIndexDocument
    def random_document(query_params)
      query_response = @index_querier.search(query_params)
      Krikri::SearchIndexDocument.new(query_response.docs.first)
    end
  end
end
