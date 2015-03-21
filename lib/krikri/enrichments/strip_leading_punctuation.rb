module Krikri::Enrichments
  ##
  # Strip leading punctuation
  #
  #   StripLeadingPunctuation.new
  #     .enrich_value("([!.;:\tmoominpapa;:;:; moominmama! ...\n")
  #   # => "\tmoominpapa;:;:; moominmama! ...\n"
  #
  # Leaves quotation marks.
  class StripLeadingPunctuation
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      value.gsub(/^[^\p{Alnum}\'\"\s]*/, '')
    end
  end
end
