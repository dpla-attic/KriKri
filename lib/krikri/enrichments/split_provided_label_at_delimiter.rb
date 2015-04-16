module Krikri::Enrichments
  ##
  # Splits a Resource into multiple resources of its own class by a given
  # delimiter in its `#providedLabel`. The full original resource is retained
  # with the first value from the split label.
  #
  # @example
  #   splitter = SplitProvidedLabelAtDelimiter.new
  #   concept = DPLA::MAP::Concept.new
  #   concept.providedLabel = 'abc; 123'
  #   concept.exactMatch = RDF::URI('http://example.org/alphabet')
  #
  #   results = splitter.enrich_value(concept)
  #
  #   results.map(&:providedLabel)
  #   # => [['abc'], ['123']]
  #
  #   results.map(&:exactMatch)
  #   # => [[#<ActiveTriple::Resource:...>], []]
  #
  # @see Krikri::FieldEnrichment
  class SplitProvidedLabelAtDelimiter
    include Krikri::FieldEnrichment

    ##
    # @param delimiter [String] a substring on which to split `#providedLabel`
    def initialize(delimiter = ';')
      @delimiter = delimiter
    end

    ##
    # @param value [Object] the value to split
    # @see Krikri::FieldEnrichment
    def enrich_value(value)
      return value unless value.is_a?(ActiveTriples::Resource) &&
                          value.respond_to?(:providedLabel)

      construct_results(value)
    end

    private

    ##
    # @param value [ActiveTriples::Resource]
    #
    # @return [Array<ActiveTriples::Resource>] an array of resources derived
    #   from the split `#providedLabel` of `value`
    def construct_results(value)
      values = split_value(value)

      value.providedLabel = values.shift
      results = [value]

      values.each { |v| results << build_resource(value.class, v) }

      results
    end

    ##
    # @param klass [Class]
    # @param providedLabel [String]
    #
    # @return [klass] a new resource of `klass` with the providedLabel given
    def build_resource(klass, providedLabel)
      resource = klass.new
      resource.providedLabel = providedLabel
      resource
    end

    ##
    # @param value [#providedLabel]
    # @return [Array<String>] a flat array of provided labels split from
    #   the original
    def split_value(value)
      value.providedLabel.map { |l| l.split(@delimiter).map(&:strip) }.flatten
    end
  end
end
