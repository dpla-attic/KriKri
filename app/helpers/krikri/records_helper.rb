module Krikri
  module RecordsHelper
    include Krikri::SearchResultsHelperBehavior

    ##
    # Return the id of a document randomly selected from the search index.
    # @param provider_id [String, nil] the id of the provider that the randomly
    # selected document will belong to.
    # @return [String, nil] the id of the randomly selected document. If none are
    #   available, gives `nil`
    def random_record_id(provider_id)
      doc = Krikri::RandomSearchIndexDocumentBuilder.new do
        self.provider_id = provider_id
      end.document

      doc.present? ? local_name(doc.id) : nil
    end
  end
end
