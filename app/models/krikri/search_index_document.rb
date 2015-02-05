module Krikri
  ##
  # Subclass of Blacklight's SolrDocument.
  # Represents a single document returned from a query to the search index.
  class SearchIndexDocument < SolrDocument

    ##
    # Get the aggregation, populated with data from Marmotta, which corresponds
    # to this SearchIndexDocument
    # @return [DPLA::MAP::Aggregation, nil]
    def aggregation
      agg = DPLA::MAP::Aggregation.new(id)
      return nil unless agg.exists?
      agg.get
      agg
    end
  end
end
