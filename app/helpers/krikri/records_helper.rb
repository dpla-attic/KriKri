module Krikri
  module RecordsHelper
    include Krikri::SearchResultsHelperBehavior

    ##
    # Return the id of a document randomly selected from the search index.
    # @param provider_id [String, nil] the id of the provider that the randomly
    # selected document will belong to.
    # @return [String] the id of the randomly selected document.
    def random_record_id(provider_id)
      doc = Krikri::RandomSearchIndexDocumentBuilder.new do
        self.provider_id = provider_id
      end.document.id
    end
  end
end
