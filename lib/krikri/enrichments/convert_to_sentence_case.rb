module Krikri::Enrichments
  ##
  # Converts a string to sentence case.
  #
  # @example
  #
  #   string = 'this is a sentence about Moomins. this is another about Snorks.'
  #   Krikri::Enrichments::ConvertToSentenceCase.enrich_value(string)
  #   # => 'This is a sentence about moomins. This is another about snorks.'
  class ConvertToSentenceCase
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      value.gsub(/([a-z])((?:[^.?!]|\.(?=[a-z]))*)/i) do
        $1.upcase + $2.downcase.rstrip
      end
    end
  end
end
