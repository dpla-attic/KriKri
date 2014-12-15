module Krikri::Enrichments
  module RemoveEmptyFields
    extend Krikri::Enrichment

    module_function

    def enrich(record)
      n = for_fields_in(record) do |val|
        val unless val.respond_to?(:empty?) and val.empty?
      end
    end
  end
end
