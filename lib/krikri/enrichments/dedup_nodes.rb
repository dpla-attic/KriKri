module Krikri::Enrichments
  ##
  # Enrichment to remove duplicate blank nodes from an
  # {ActiveTriples::Resource}, where "duplicate" means having the same
  # `providedLabel`. URIs and Literal values are retained.
  #
  # @example
  #   # given a SourceResource
  #   sourceResource.creator
  #   # => [#<DPLA::MAP::Agent:0x3fa8828e08e0(default)>,
  #         #<DPLA::MAP::Agent:0x3fa882910220(default)>,
  #         #<DPLA::MAP::Agent:0x3fa882942ce8(default)>]
  #
  #   sourceResource.creator.map(&:rdf_subject)
  #   # => [#<RDF::Node:0x3fa8828e0674(_:g69992977401460)>,
  #         #<RDF::Node:0x3fa882913d08(_:g69992977612040)>,
  #         #<RDF::URI:0x3fa882942748 URI:http://example.org/moomin>]
  #   sourceResource.creator.map(&:providedLabel)
  #   # => [["moomin"], ["moomin"], ["moomin"]]
  #
  #   enrich = Krikri::Enrichments::DedupNodes.new
  #   new_sr = enrich.enrich_value(sourceResource)
  #
  #   new_sr.creator
  #   # => [#<DPLA::MAP::Agent:0x3fa8828e08e0(default)>,
  #         #<DPLA::MAP::Agent:0x3fa882942ce8(default)>]
  #
  #   sourceResource.creator.map(&:rdf_subject)
  #   # => [#<RDF::Node:0x3fa8828e0674(_:g69992977401460)>,
  #         #<RDF::URI:0x3fa882942748 URI:http://example.org/moomin>]
  #
  class DedupNodes
    include Audumbla::FieldEnrichment

    ##
    # @param value [Object]
    #
    # @return [Object] the original value altered to remove nodes with the same
    #   `providedLabel`, if any
    def enrich_value(value)
      return value unless value.is_a? ActiveTriples::Resource
      deduplicate_resource(value)
      value
    end

    private

    ##
    # @param value [ActiveTriples::Resource]
    #
    # @return [ActiveTriples::Resource] returns the node after running `#uniq`
    #   against the provided labels of an nodes.
    def deduplicate_resource(value)
      value.class.properties.values.map(&:term).map do |property|
        unique = value.send(property).uniq { |v| providedLabel_or_value(v) }
        value.send("#{property}=".to_sym, unique)
      end
    end

    ##
    # @param value [Object]
    #
    # @return [Object] if `value` is an RDF::Node, the first result of its
    #   `#providedLabel`, if any; otherwise the original `value`.
    def providedLabel_or_value(value)
      return value unless value.respond_to? :providedLabel
      return value unless value.node?
      return value.providedLabel.first if value.providedLabel.any?
      value
    end
  end
end
