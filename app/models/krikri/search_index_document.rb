module Krikri
  ##
  # Subclass of Blacklight's SolrDocument.
  # Represents a single document returned from a query to the search index.
  class SearchIndexDocument < SolrDocument

    ##
    # Use local name instead of full item id URI in route.  For example, a
    # document with the id 'http://dp.la/marmotta/ldp/items/123ab' will have an
    # id param of '123ab'.  This is necessary because routes that contain '.' 
    # are not valid.
    # @return String
    def to_param
      self[self.class.unique_key].match(/[\/]([^\/]*)\z/)[1]
    end

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
