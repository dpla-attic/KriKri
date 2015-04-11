module Krikri::Enrichments
  ##
  # Copies non-DCMI Type values from the input fields to the output fields.
  # If
  class MoveNonDcmiType
    include Krikri::Enrichment

    ##
    # @param value [Object] the value to enrich
    #
    # @return [Object, nil] the existing value, if it is NOT a DCMI Type value
    def enrich_value(value)
      return nil if value.is_a? DPLA::MAP::Controlled::DCMIType
      value
    end
  end
end
