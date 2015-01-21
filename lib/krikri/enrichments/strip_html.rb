module Krikri::Enrichments
  ##
  # Enrichment to capitalize sentences in a text field
  #
  #   StripHtml.new.enrich_value('<html>Moomin <i><b>Valley</i></b>')
  #   => 'Moomin Valley'
  #
  class StripHtml
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      ActionView::Base.full_sanitizer.sanitize(value)
    end
  end
end
