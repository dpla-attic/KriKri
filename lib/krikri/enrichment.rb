module Krikri
  module Enrichment
    extend SoftwareAgent

    ##
    # @abstract The main enrichment method; runs the enrichment against a record
    #
    # @param record [ActiveTriples::Resource] the record to enrich
    # @return [ActiveTriples::Resource] the enriched record
    def enrich(_)
      raise NotImplementedError
    end

    def for_fields_in(record, &block)
      record = record.clone
      for_each_property(record, &block)
      record
    end

    def run(records)
      Krikri::Activity.new(self) do
      end
    end

    private

    def for_each_property(record, &block)
      record.class.properties.each do |prop, config|
        new_vals = record.send(prop.to_sym).map do |value|
          if value.is_a? ActiveTriples::Resource
            for_fields_in(value, &block)
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
