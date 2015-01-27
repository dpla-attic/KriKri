module Krikri::Enrichments
  ##
  # Converts text fields and/or providedLabels to ISO 689-3 URIs (Lexvo)
  #
  # Transforms text values matching either (English) labels or ISO language
  # codes from Lexvo into DPLA::MAP::Controlled::Language resources with
  # appropriate URIs.
  #
  # For example:
  #   'fin'     => 'http://lexvo.org/id/iso639-3/fin'
  #   'finnish' => 'http://lexvo.org/id/iso639-3/fin'
  #   'eng'     => 'http://lexvo.org/id/iso639-3/eng'
  #   'english' => 'http://lexvo.org/id/iso639-3/eng'
  #
  # If passed an ActiveTriples::Resource, the enrichment will:
  #
  #   - Perform the above text matching on any present `provededLabel`s,
  #     returning empty if no matches are found.  If multiple values are
  #     provided and multiple matches found, they will be deduplicated.
  #   - Leave DPLA::MAP::Controlled::Language objects that are not bnodes
  #     unaltered.
  #   - Remove any values which are not either bnodes or members of
  #     DPLA::MAP::Controlled::Language.
  #
  # This enrichment sets `providedLabel` on any generated resource.
  class IsoEnrich
    include Krikri::FieldEnrichment

    def enrich_value(value)
      return enrich_node(value) if value.is_a?(ActiveTriples::Resource) &&
        value.node?
      return value if value.is_a?(DPLA::MAP::Controlled::Language)
      return nil if value.is_a?(ActiveTriples::Resource)
      enrich_literal(value)
    end

    def enrich_node(value)
      labels = value.get_values(RDF::DPLA.providedLabel)
      return nil if labels.empty?
      langs = labels.map { |label| enrich_literal(label) }
      langs.compact.uniq(&:rdf_subject)
    end

    def enrich_lang(value)
      value.fetch
      value
    end

    def enrich_literal(label)
      return nil unless label.to_s
      match = match_iso(label.to_s)
      match ||= match_label(label.to_s)
      match.providedLabel = label unless match.nil?
      match
    end

    def match_iso(label)
      from_terms(terms.map { |t| t.qname[1] }.select { |c| c == label.to_sym })
    end

    def match_label(label)
      matches = terms.select do |t|
        Array(t.label).map(&:downcase).include? label.downcase
      end

      from_terms(matches)
    end

    def terms
      DPLA::MAP::Controlled::Language.list_terms
    end

    private

    def from_terms(codes)
      raise 'Found more than one matching ISO 639-3 codes: #{codes}' unless
        codes.count <= 1
      return nil if codes.empty?
      DPLA::MAP::Controlled::Language.new(codes.first)
    end
  end
end
