module Krikri::Enrichments
  class RemoveEmptyFields
    include Krikri::Enrichment

    def enrich_value(value)
      (value.respond_to?(:empty?) && value.empty?) ? nil : value
    end
  end
end
