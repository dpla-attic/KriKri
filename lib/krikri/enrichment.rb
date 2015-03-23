module Krikri
  ##
  # Mixin module for enriching a set of input_fields and setting the resulting
  # values to a set of output fields.
  module Enrichment
    ##
    # The main enrichment method; passes specified input fields to
    # #enrich_values, which must return an array of values with length equal to
    # the number of output fields. The values of the output fields are set to
    # the corresponding result from the enrichment.
    #
    # Pass fields to `input_fields` and `output_fields`. Fields are formatted
    # as symbols in nested hashes, targeting a particular field in an
    # ActiveTriples Resource property hierarchy:
    #
    #   :sourceResource
    #   {:sourceResource => :spatial}
    #   {:sourceResource => {:creator => :name}}
    #
    # The record passed in is not altered, but cloned before the enrichment is
    # applied. A common pattern may be:
    #
    #   record = my_enrichment.enrich(record, input, output)
    #   record.persist!
    #
    # Input fields create an array selecting the values of all matching fields.
    # For example:
    #
    # an array of values from record.sourceResource:
    #   :sourceResource
    #
    # an array of values combining spatial fields from the values of
    # record.sourceResource:
    #   {:sourceResource => :spatial}
    #
    # an array of values combining name fields from the creators in
    # record.sourceResource:
    #   {:sourceResource => {:creator => :name}}
    #
    #
    # Output fields should be specified at a high enough level that the
    # enrichment can build a complete value set from the input values provided.
    # An enrichment for mapping names to LCSH URIs, that alters all creator
    # fields might be formatted:
    #
    #   my_enrichment.enrich(record,
    #     [{:sourceResource => {:creator => :providedLabel}}],
    #     [{:sourceResource => :creator}])
    #
    # This would pass the values like the following, sourced from the
    # providedLabel, to #enrich_value:
    #
    #   [['Moomintroll', 'Moomin Papa', 'Moomin Mama']]
    #
    # And it would expect to receive an array of values set directly to creator,
    # overwriting all existing creator values:
    #
    #   [DPLA::MAP::Agent:0x3ff(default),
    #    DPLA::MAP::Agent:0x9f5(default),
    #    DPLA::MAP::Agent:0x3a8(default)]
    #
    # @param record [ActiveTriples::Resource] the record to enrich
    # @param input_fields [Array] the fields whose values to pass to the
    #   enrichment method
    # @param output_fields [Array] the fields on which to apply the enrichment
    # @return [ActiveTriples::Resource] the enriched record
    def enrich(record, input_fields, output_fields)
      enrich!(record.clone, input_fields, output_fields)
    end

    ##
    # @see Krikri::Enrichment#enrich
    def enrich!(record, input_fields, output_fields)
      output_fields.map! { |f| field_to_chain(f) }

      values = values_from_fields(record, input_fields)
      values = enrich_value(values).dup

      raise 'field/value mismatch.' \
        "#{values.count} values for #{output_fields.count} fields." unless
        values.count == output_fields.count

      output_fields.each { |field| set_field(record, field, values.shift) }
      record
    end

    ##
    # @abstract Runs the enrichment against a field
    #
    # Accept an array of values from an ActiveTriples::Resource property, and
    # return an array of values to set to output fields.
    #
    # @param [ActiveTriples::Resource, RDF::Literal] the value(s) to process
    # @return [ActiveTriples::Resource] the enriched record
    def enrich_value(_)
      raise NotImplementedError
    end

    def list_fields(record)
      fields = []
      record.class.properties.each do |prop, _|
        fields << prop.to_sym

        objs = resources(record.send(fields.last)).map { |r| list_fields(r) }
        next if objs.empty?

        objs.flatten.each { |obj| fields << { prop => obj } }
      end
      fields
    end

    private

    def values_for_field(record, field_chain)
      values = record.send(field_chain.first)
      return values if field_chain.length == 1
      resources(values).map { |v| values_for_field(v, field_chain[1..-1]) }
        .flatten.compact
    end

    def set_field(record, field_chain, values)
      field = field_chain.pop
      return record.send("#{field}=".to_sym, values) if field_chain.length == 0
      values_for_field(record, field_chain).each do |obj|
        obj.send("#{field}=".to_sym, values)
      end
    end

    def resources(values)
      values.select { |v| v.is_a? ActiveTriples::Resource }
    end

    def literals(values)
      values.select { |v| !v.is_a?(ActiveTriples::Resource) }
    end

    def field_to_chain(field)
      return Array(field) if field.is_a? Symbol
      [field.keys.first, field_to_chain(field.values.first)].flatten
    end

    def values_from_fields(record, input_fields)
      input_fields.map { |f| values_for_field(record, field_to_chain(f)) }
    end
  end
end
