module Krikri::Enrichments
  ##
  # Strip whitespace
  #
  #   StripWhitespace.new.enrich_value("\tmoominpapa  \t  \nmoominmama  ")
  #   # => ['moominpapa', 'moominmama']
  class StripWhitespace
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      value.strip.gsub(/\s+/, ' ')
    end
  end
end
