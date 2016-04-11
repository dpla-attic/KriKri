module Krikri::Enrichments
  ##
  # Converts text fields and/or providedLabels to ISO 639-3 URIs (Lexvo)
  #
  # Transforms text values matching either (English) labels or language codes
  # from Lexvo into DPLA::MAP::Controlled::Language resources with
  # skos:exactMatch of the appropriate Lexvo URIs. Original string values are
  # retained as dpla:providedLabel.
  #
  # Currently suppports langague codes in ISO 639-3, but may be extended to
  # matchother two and three letter codes in Lexvo with ISO 639-3 URIs.
  #
  # @example matching string values
  #   iso = LanguageToLexvo.new
  #   iso.enrich_value('fin')     # matches 'http://lexvo.org/id/iso639-3/fin'
  #   iso.enrich_value('finnish') # matches 'http://lexvo.org/id/iso639-3/fin'
  #   iso.enrich_value('eng')     # matches 'http://lexvo.org/id/iso639-3/eng'
  #   iso.enrich_value('english') # matches 'http://lexvo.org/id/iso639-3/eng'
  #   iso.enrich_value('English') # matches 'http://lexvo.org/id/iso639-3/eng'
  #
  # If no matches are found, returns a bnode with the input value as
  # providedLabel.
  #
  # If passed an ActiveTriples::Resource, the enrichment will:
  #
  #   - Perform the above text matching on any present `providedLabel`s,
  #     returning the original node if no results are found.  If multiple
  #     values are provided and multiple matches found, they will be
  #     deduplicated.
  #   - Leave DPLA::MAP::Controlled::Language objects that are not bnodes
  #     unaltered.
  #   - Remove any values which are not either bnodes or members of
  #     DPLA::MAP::Controlled::Language.
  #
  # @example matching node values
  #   iso = LanguageToLexvo.new
  #   lang = DPLA::MAP::Controlled::Language.new
  #   lang.providedLabel = 'eng'
  #   iso.enrich_value(lang)     # matches ['http://lexvo.org/id/iso639-3/fin']
  #   lang.providedLabel = 'fin', 'eng'
  #   iso.enrich_value(lang)     # matches ['http://lexvo.org/id/iso639-3/fin',
  #                              #          'http://lexvo.org/id/iso639-3/eng']
  #
  # Label matches are cached within the enrichment instance, 
  #
  # @see DPLA::MAP::Controlled::Language
  # @see http://www.lexvo.org/
  class LanguageToLexvo
    include Audumbla::FieldEnrichment

    TERMS = RDF::ISO_639_3.to_a
    QNAMES = TERMS.map { |t| t.qname[1] }.freeze

    ##
    # Runs the enrichment against a node. Can match literal values, and Language
    # values with a provided label.
    #
    # @example with a matching value
    #   lang = enrich_value('finnish')
    #   #=> #<DPLA::MAP::Controlled::Language:0x3f(default)>
    #   lang.providedLabel
    #   #=> ['finnish']
    #   lang.exactMatch.map(&:to_term)
    #   #=> [#<RDF::Vocabulary::Term:0x9b URI:http://lexvo.org/id/iso639-3/fin>]
    #
    # @example with no match
    #   lang = enrich_value('moomin')
    #   #=> #<DPLA::MAP::Controlled::Language:0x3f(default)>
    #   lang.providedLabel
    #   #=> ['moomin']
    #   lang.exactMatch
    #   #=> []
    #
    # @param value [ActiveTriples::Resource, #to_s]
    # @return [DPLA::MAP::Controlled::Language, nil] a resource representing the
    #   language match.
    def enrich_value(value)
      return enrich_node(value) if value.is_a?(ActiveTriples::Resource) &&
        value.node?
      return value if value.is_a?(DPLA::MAP::Controlled::Language)
      return nil if value.is_a?(ActiveTriples::Resource)
      enrich_literal(value)
    end

    ##
    # Runs the enrichment over a specific node, accepting an
    # `ActiveTriples::Resource` with a provided label and returning a new node
    # with a lexvo match.
    #
    # @param value [ActiveTriples::Resource] a resource with a
    #   `dpla:providedLabel`
    # @return [Array<ActiveTriples::Resource>, ActiveTriples::Resource]
    def enrich_node(value)
      labels = value.get_values(RDF::DPLA.providedLabel)
      return value if labels.empty?
      labels.map { |label| enrich_literal(label) }
    end

    ##
    # Runs the enrichment over a string.
    #
    # @param label [#to_s] the string to match
    # @return [ActiveTriples::Resource] a blank node with a `dpla:providedLabel`
    #   of `label` and a `skos:exactMatch` of the matching lexvo language,
    #   if any
    def enrich_literal(label)
      node = DPLA::MAP::Controlled::Language.new()
      node.providedLabel = label

      match = match_iso(label.to_s)
      match = match_label(label.to_s) if match.node?

      # if match is still a node, we didn't find anything
      return node if match.node?

      node.exactMatch = match 
      node.prefLabel = RDF::ISO_639_3[match.rdf_subject.qname[1]].label.last
      node
    end

    ##
    # Converts string or symbol for a three letter language code to an
    # `ActiveTriples::Resource`.
    #
    # @param code [#to_sym] a three letter iso code
    # @return [DPLA::MAP::Controlled::Language]
    def match_iso(code)
      match = QNAMES.find { |c| c == code.downcase.to_sym }
      from_sym(match)
    end

    ##
    # Converts string or symbol for a language label to an
    # `ActiveTriples::Resource`.
    # 
    # Matched values are cached in an instance variable `@lang_cache` to avoid
    # multiple traversals through the vocabulary term labels.
    #
    # @param code [#to_sym] a string to match against a language label
    # @return [DPLA::MAP::Controlled::Language]
    def match_label(label)
      @lang_cache ||= {}
      return @lang_cache[label] if @lang_cache.keys.include? label

      match = TERMS.find do |t|
        Array(t.label).map(&:downcase).include? label.downcase
      end
      
      # Caches and returns the the label match
      @lang_cache[label] = from_sym(match)
    end

    private

    ##
    # @param code [#to_s] A language code to convert to a URI
    # @return [DPLA::MAP::Controlled::Language] a language Resource with the 
    #   matching code as the URL's local name. this will be a Node if code is
    #   `nil`
    def from_sym(code)
      DPLA::MAP::Controlled::Language.new(code)
    end
  end
end
