module Krikri::Enrichments
  ##
  # Enrichment to remove WebResources that are blank nodes. `edm:WebResource`
  # nodes should *always* be an HTTP URI.
  class WebResourceURI
    include Audumbla::FieldEnrichment

    ##
    # @param [Object] value
    #
    # @return [Object] `nil` if `value` is a `DPLA::MAP::WebResource` and a 
    #    blank node; otherwise, the original `value`.
    def enrich_value(value)
      return value unless value.is_a?(DPLA::MAP::WebResource) && value.node?
      nil
    end
  end
end
  
  
