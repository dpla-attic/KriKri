module Krikri::Enrichments
  ##
  # Enrichment to limit the number of characters in a string to 1000
  #
  #  @example: Limit a String
  #  LimitCharacters.new.enrich_value(string_with_over_1000_characters)
  #   => truncated string ending in '...'
  #
  class LimitCharacters
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      return value unless value.length > 1000
      value.truncate(1000, separator: /\s/)
    end
  end
end
