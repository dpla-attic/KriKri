module Krikri::Enrichments
  ##
  # Strip leading colons
  #
  #   StripLeadingColons.new.enrich_value(";:\tmoominpa()pa;;;")
  #   # => "\tmoominpa()pa;;;"
  class StripLeadingColons
    include Audumbla::FieldEnrichment

    def enrich_value(value)
      return value unless value.is_a? String
      value.gsub(/^[\;\:]*/, '')
    end
  end
end
