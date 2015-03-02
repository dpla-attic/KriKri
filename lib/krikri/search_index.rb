require 'rubygems'
require 'rsolr'

module Krikri
  ##
  # Search index base class that gets extended by QA and Production index
  # classes
  class SearchIndex
    def initialize(_)
      @bulk_update_size = 10
    end

    ##
    # Add a single JSON document to the search index.
    # Implemented in a child class.
    # @param _ [String] JSON document
    def add(_)
      fail NotImplementedError
    end

    ##
    # Add a number of JSON documents to the search index at once.
    # Implemented in a child class.
    # @param _ [Array] Strings of JSON documents
    def bulk_add(_)
      fail NotImplementedError
    end

    ##
    # Update or save all records in the index that were affected by the given
    # Activity.
    # @param activity [Krikri::Activity]
    def update_from_activity(activity)
      fail "#{activity} is not an Activity" \
        unless activity.class == Krikri::Activity
      begin
        bulk_update_from_activity(activity)
      rescue NotImplementedError
        incremental_update_from_activity(activity)
      end
    end

    protected

    ##
    # @param activity [Krikri::Activity]
    def bulk_update_from_activity(activity)
      agg_batches = bulk_update_batches(activity.aggregations_as_json)
      agg_batches.each do |batch|
        bulk_add(batch)
      end
    end

    ##
    # @param aggregations [Enumerator]
    # @return [Enumerator] Each array of JSON strings
    def bulk_update_batches(aggregations)
      Enumerator.new do |e|
        i = 1
        batch = []
        aggregations.each do |agg|
          batch << agg
          if i % @bulk_update_size == 0
            e.yield batch
            i += 1
            batch = []
          end
        end
        e.yield batch if batch.count > 0  # last one
      end
    end

    ##
    # @param activity [Krikri::Activity]
    def incremental_update_from_activity(activity)
      activity.aggregations_as_json.each do |agg|
        add(agg)
      end
    end
  end


  ##
  # Generates flattened Solr documents and manages indexing of DPLA MAP models.
  #
  # @example
  #
  #   indexer = Krikri::QASearchIndex.new
  #   agg = Krikri::Aggregation.new
  #   json_doc = agg.to_jsonld['@graph'].first.to_json
  #
  #   indexer.add(json_doc)
  #   indexer.commit
  #
  class QASearchIndex < Krikri::SearchIndex
    attr_reader :solr

    ##
    # @param opts [Hash] options to pass to RSolr
    # @see RSolr.connect
    def initialize(opts = Krikri::Settings.solr.to_h)
      @solr = RSolr.connect(opts)
      super(opts)
    end

    # TODO: Assure that the following metacharacters are escaped:
    # + - && || ! ( ) { } [ ] ^ " ~ * ? : \

    ##
    # Adds a single JSON document to Solr
    # @param JSON
    def add(doc)
      solr.add solr_doc(doc)
    end

    ##
    # Deletes an item from Solr
    # @param String or Array
    def delete_by_id(id)
      solr.delete_by_id id
    end

    ##
    # Deletes items from Solr that match query
    # @param String or Array
    def delete_by_query(query)
      solr.delete_by_query query
    end

    ##
    # Commits changes to Solr, making them visible to new requests
    # Should be run after self.add and self.delete
    # Okay to add or delete multiple docs and commit them all with
    # a single self.commit
    def commit
      solr.commit
    end

    ##
    # Converts JSON document into a Hash that complies with Solr schema
    # @param [JSON]
    # @return [Hash]
    def solr_doc(doc)
      remove_invalid_keys(flat_hash(JSON.parse(doc)))
    end

    ##
    # Get field names from Solr schema in host application.
    # Will raise exception if file not found.
    # @return [Array]
    def schema_keys
      schema_file = File.join(Rails.root, 'solr_conf', 'schema.xml')
      file = File.open(schema_file)
      doc = Nokogiri::XML(file)
      file.close
      doc.xpath('//fields/field').map { |f| f.attr('name') }
    end

    private

    ##
    # Flattens a nested hash
    # Joins keys with "_" and removes "@" symbols
    # Example:
    #   flat_hash( {"a"=>"1", "b"=>{"c"=>"2", "d"=>"3"} )
    #   => {"a"=>"1", "b_c"=>"2", "b_d"=>"3"}
    def flat_hash(hash, keys = [])
      new_hash = {}

      hash.each do |key, val|

        if val.is_a? Hash
          new_hash.merge!(flat_hash(val, keys + [key]))
        else
          new_hash[format_key(keys + [key])] = val
        end
      end

      new_hash
    end

    ##
    # Formats a key to match a field name in the Solr schema
    #
    # Removes unnecessary special character strings that would
    # require special treatment in Solr
    #
    # @param Array
    #
    # TODO: Revisit this to make it more generalizable
    def format_key(keys)
      keys.join('_')
        .gsub('@', '')
        .gsub('http://www.geonames.org/ontology#', '')
        .gsub('http://www.w3.org/2003/01/geo/wgs84_pos#', '')
    end

    ##
    # Remove keys (ie. fields) that are not in the Solr schema.
    # @param [Hash]
    # @return [Hash]
    def remove_invalid_keys(solr_doc)
      valid_keys = schema_keys
      solr_doc.delete_if { |key, _| !key.in? valid_keys }
    end
  end


  ##
  # Production ElasticSearch search index class
  class ProdSearchIndex < Krikri::SearchIndex
    ##
    # @todo Define ElasticSearch connection
    def initialize(opts)
      super(opts)
    end

    ##
    # Add a single JSON document to the production ElasticSearch search index.
    # @param doc [String] JSON document
    # @todo Fill in
    def add(doc)
      true
    end

    ##
    # Add a number of JSON documents to the search index at once.
    # @param docs [Array] Strings of JSON documents
    # @todo Fill in
    def bulk_add(docs)
      true
    end
  end
end
