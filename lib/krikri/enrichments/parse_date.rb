module Krikri::Enrichments
  ##
  # Normalizes date strings to
  #
  #   StripPunctuation.new.enrich_value("\tmo!ominpa)(pa  \n .$%^ moominmama  ")
  #   # => "\tmoominpapa  \n  moominmama  "
  class ParseDate
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      date = Date.edtf(value)
      begin
        date ||= (parse_m_d_y(value) || Date.parse(value))
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
