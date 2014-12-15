module Krikri::Enrichments
  ##
  # Enrichment to split fields at a specified delimiter
  #
  #   splitter = SplitAtDelimiter.new(',')
  #   splitter.enrich_value('moominpapa, moominmama')
  #   # => ['moominpapa', 'moominmama']
  class SplitAtDelimiter
    include Krikri::FieldEnrichment

    attr_accessor :delimiter

    def initialize(delimiter = ';')
      @delimiter = delimiter
    end

    def enrich_value(value)
      return value unless value.respond_to? :split
      value.split(delimiter).map(&:strip)
    end
  end
end
