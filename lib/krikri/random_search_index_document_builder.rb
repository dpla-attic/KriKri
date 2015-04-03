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
      solr_response = Krikri::SolrResponseBuilder.new(query_params)
      return nil if solr_response.response.docs.empty?

      Krikri::SearchIndexDocument.new(solr_response.response.docs.first)
    end

    private

    ##
    # Parameters for the Solr request.
    # Limits search by @provider_id if it has been specified.
    def query_params
      params = { :id => '*:*',
                 :sort => "random_#{rand(9999)} desc",
                 :rows => 1 }
      return params unless provider_id.present?

      provider = RDF::URI(Krikri::Provider.base_uri) / provider_id
      params[:fq] = "provider_id:\"#{provider}\""
      params
    end
  end
end
