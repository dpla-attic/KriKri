module Krikri::Enrichments
  ##
  # Normalizes date strings to EDTF or Date objects.
  #
  # Attempts to convert a string value to a Date object:
  #
  #   - Parses EDTF values, returns an appropriate EDTF object if
  #     a match is found; then...
  #   - Parses values in %m*%d*%Y format and returns a Date object if
  #     appropriate.
  #   - Parses values that match any of Date#parse's supported formats.
  #
  # If the value is not a `String` or is parsed as invalid by all
  # parsers, the original value is returned unaltered.
  #
  # @see Date#parse
  # @see https://github.com/inukshuk/edtf-ruby/blob/master/README.md Ruby EDTF
  # @see http://www.loc.gov/standards/datetime/pre-submission.html EDTF Draft
  class ParseDate
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      date = Date.edtf(value)
      begin
        date || (parse_m_d_y(value) || Date.parse(value))
      rescue ArgumentError
        value
      end
    end

    def parse_m_d_y(value)
      begin
        Date.strptime(value.gsub(/[^0-9]/, '-'), '%m-%d-%Y')
      rescue ArgumentError
        nil
      end
    end
  end
end
