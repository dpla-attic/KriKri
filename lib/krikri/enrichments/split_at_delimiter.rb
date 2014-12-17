module Krikri::Enrichments
  class SplitAtDelimiter
    include Krikri::FieldEnrichment

    attr_accessor :delimiter

    def initialize(delimiter=';')
      @delimiter = delimiter
    end

    def enrich_value(value)
      return value unless value.respond_to? :split
      value.split(delimiter).map(&:strip)
    end
  end
end
