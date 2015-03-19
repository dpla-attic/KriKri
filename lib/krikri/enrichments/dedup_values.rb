module Krikri::Enrichments
  ##
  #
  class DedupValues
    include Krikri::FieldEnrichment

    ##
    # Runs the enrichment on a given value
    #
    # @params value the value whose memebers to deduplicate
    # @return the deduplicated value
    def enrich_value(value)
      return value unless value.is_a? ActiveTriples::Resource
      properties = properties_with_provided_label(value)
      properties.each { |prop| dedup_property(value, prop) }
      value
    end

    private

    def dedup_property(value, property)
      new_values = value.get_values(property).uniq do |v|
        v.respond_to?(:providedLabel) ? v.providedLabel.first : v
      end
      value.set_value(property, new_values)
    end

    def properties_with_provided_label(value)
      props = value.class.properties.select do |_, config|
        config.class_name.properties.include?('providedLabel') unless
          config.class_name.nil?
      end
      props.keys
    end
  end
end
