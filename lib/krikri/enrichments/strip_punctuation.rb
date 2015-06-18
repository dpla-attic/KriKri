module Krikri::Enrichments
  ##
  # Strip punctuation
  #
  #   StripPunctuation.new.enrich_value("\tmo!ominpa)(pa  \n .$%^ moominmama  ")
  #   # => "\tmoominpapa  \n  moominmama  "
  class StripPunctuation
    include Audumbla::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      value.gsub(/[^\p{Alnum}\'\"\s]/, '')
    end
  end
end
