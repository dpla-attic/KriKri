module Krikri::Enrichments
  ##
  # Removes non-DCMI Type values from a field
  class DcmiEnforcer
    include Audumbla::FieldEnrichment

    ##
    # @param value [Object] the value to enrich
    #
    # @return [DPLA::MAP::Controlled::DCMIType, nil] the original value or `nil`
    def enrich_value(value)
      return nil unless value.is_a? DPLA::MAP::Controlled::DCMIType
      return nil unless value.valid?
      value
    end
  end
end
