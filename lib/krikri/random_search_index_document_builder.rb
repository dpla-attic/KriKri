module Krikri
  # Gets random records from the search index
  class RandomSearchIndexDocumentBuilder
    attr_accessor :provider_id

    ##
    # @param &block may contain provider_id
    #   Sample use:
    #     RandomSearchIndexDocumentBuilder.new do
    #       self.provider_id = '0123'
    #     end
    def initialize(&block)
      # set values from block 
      instance_eval &block if block_given?
    end

    # @return Krikri::SearchIndexDocument
    def document
      Krikri::SearchIndexDocument.new(Krikri::SolrResponseBuilder
        .new(query_params).response.docs.first)
    end

    private

    ##
    # Parameters for the Solr request.
    # Limits search by @provider_id if it has been specified.
    def query_params
      params = { :id => '*:*',
                 :sort => "random_#{rand(9999)} desc",
                 :rows => 1 }
      params[:fq] = "provider_id:\"#{@provider_id}\"" if @provider_id.present?
      params
    end
  end
end
