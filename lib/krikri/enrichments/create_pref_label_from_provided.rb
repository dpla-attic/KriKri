module Krikri::Enrichments
  ##
  # Given an field that accepts both `providedLabel` and `prefLabel`, copies 
  # the first `providedLabel` into `prefLabel` unless one is already present.
  #
  # Only the first `providedLabel` is copied, avoiding conflicts with SKOS's 
  # limit of one `skos:prefLabel` per language tag.
  #
  # Fields are ignored and returned as-is if:
  #   - they are not `ActiveTriples::Resource`
  #   - they do not respond to `#providedLabel`
  #   - they already have a `prefLabel`
  #   - there are no `providedLabel`s present
  # 
  # @example enriching a resource with a providedLabel
  #   label_enricher = CreatePrefLabelFromProvided.new
  #
  #   resource.providedLabel = 'moomin'
  #   label_enricher.enrich_value(resource)
  #   resource.dump :ttl
  #   # [
  #   #   a <http://www.europeana.eu/schemas/edm/Agent>;
  #   #   <http://dp.la/about/map/providedLabel> "moomin";
  #   #   <http://www.w3.org/2004/02/skos/core#prefLabel> "moomin"
  #   # ] .
  #   
  # @see http://www.w3.org/2012/09/odrl/semantic/draft/doco/skos_prefLabel.html
  #   for information about skos:prefLabel
  # @see Audumbla::FieldEnrichment
  class CreatePrefLabelFromProvided
    include Audumbla::FieldEnrichment

    ##
    # @param value [Object] the value to split
    # @see Audumbla::FieldEnrichment#enrich_value
    def enrich_value(value)
      return value unless value.is_a?(ActiveTriples::Resource) &&
                          value.respond_to?(:providedLabel)
      add_pref_label(value)
    end

    private
    
    ##
    # Returns the same value originally given. If a `skos:prefLabel` is not 
    # present, one is derived from the first `providedLabel` (if any).
    #
    # @param [ActiveTriples::Resource] value  the resource to enrich
    # @return [ActiveTriples::Resource] the original value, after adding a 
    #   prefLabel
    def add_pref_label(value)
      return value if value.providedLabel.empty?
      return value unless value.get_values(RDF::SKOS.prefLabel).empty?
      value.set_value(RDF::SKOS.prefLabel, value.providedLabel.first)
      value
    end
  end
end
