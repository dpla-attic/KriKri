module Krikri
  module Enrichment
    extend SoftwareAgent

    ##
    # The main enrichment method; runs the enrichment against a record
    #
    # @param record [ActiveTriples::Resource] the record to enrich
    # @param fields [Array] the fields on which to apply the enrichment
    # @return [ActiveTriples::Resource] the enriched record
    def enrich(record, *fields)
      record = record.clone
      return enrich_all(record) if (fields.empty? || fields == [:all])
    end

    ##
    # @abstract Runs the enrichment against a field
    #
    # @param [ActiveTriples::Resource, RDF::Literal] value the value to process
    # @return [ActiveTriples::Resource] the enriched record
    def enrich_value(value)
      raise NotImplementedError
    end

    def enrich_field(record, field_chain)
      field = field_chain.first
      values = record.send(field)
      if field_chain.length == 1
        new_values = values.map { |v| enrich_value(v) }.compact
        record.send("#{field}=".to_sym, new_values)
      else
        resources(values).each { |v| enrich_field(v, field_chain[1..-1]) }
      end
      record
    end

    def enrich_all(record)
      # list_fields(record).each do |field|
      #   enrich_field(record)
      # end
      # record
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
        resources = resources(record.send(prop))
        fields << {prop => resources.map { |r| list_fields(r) }.flatten} unless
          resources.empty?
      end
      fields
    end

    private

    def resources(values)
      values.select { |v| v.is_a? ActiveTriples::Resource }
    end

    def literals(values)
      values.select { |v| !v.is_a?(ActiveTriples::Resource) }
    end

    def for_each_property(record, &block)
      record.class.properties.each do |prop, _|
        new_vals = record.send(prop.to_sym).map do |value|
          if value.is_a? ActiveTriples::Resource
            enrich_all(value, &block)
          else
            yield value
          end
        end
        new_vals.select! { |v| ! v.nil? }
        record.send("#{prop}=".to_sym, new_vals)
      end
    end
  end
end
