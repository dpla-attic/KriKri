module Krikri
  module Enrichment
    extend SoftwareAgent

    def enrich(record, input_fields, output_fields)
      record = record.clone
      output_fields.map! { |f| field_to_chain(f) }

      values =
        input_fields.map { |f| values_for_field(record, field_to_chain(f)) }
      values = enrich_value(values)

      raise 'field/value mismatch.' /
        "#{values.count} values for #{output_fields.count} fields." unless
        values.count == output_fields.count

      output_fields.each do |field|
        set_field(record, field, values.shift)
      end
      record
    end

    ##
    # @abstract Runs the enrichment against a field
    #
    # @param [ActiveTriples::Resource, RDF::Literal] the value(s) to process
    # @return [ActiveTriples::Resource] the enriched record
    def enrich_value(_)
      raise NotImplementedError
    end

    ##
    # Run the enrichment over a number of records as an activity
    def run(records)
      Krikri::Activity.new(self) do
      end
    end

    def list_fields(record)
      fields = []
      record.class.properties.each do |prop, _|
        prop = prop.to_sym

        fields << prop
        resources = resources(record.send(prop)).map { |r| list_fields(r) }
        next if resources.empty?

        resources.flatten.each do |resource|
          fields << {prop => resource}
        end
      end
      fields
    end

    def values_for_field(record, field_chain)
      field = field_chain.shift
      values = record.send(field)
      return values if field_chain.length == 0
      resources(values).map { |v| values_for_field(v, field_chain) }.flatten
        .compact
    end

    def set_field(record, field_chain, values)
      field = field_chain.pop
      return record.send("#{field}=".to_sym, values) if field_chain.length == 0
      values_for_field(record, field_chain).each do |obj|
        obj.send("#{field}=".to_sym, values)
      end
    end

    private

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
  end
end
