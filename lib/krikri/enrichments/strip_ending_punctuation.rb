module Krikri::Enrichments
  ##
  # Strip ending punctuation
  #
  #   StripEndingPunctuation.new
  #     .enrich_value("moomin!...!;,.",)
  #   # => "moomin"
  #
  # Leaves quotation marks and closing parentheses & brackets. Also
  # leaves periods when they follow a one or two letter abbreviation.
  class StripEndingPunctuation
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      value.gsub!(/[^\p{Alnum}\'\"\)\]\}]*$/, '') unless
        value.match /\s*[a-z]{1,2}\.$/i
      value
    end
  end
end
