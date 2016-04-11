module Krikri::Enrichments
  ##
  # Splits a resource into multiple resources when multiple providedLabels are
  # present. This is useful when a mapping error or limitation in partner data
  # makes it impossible to split resoureces properly at mapping time.
  #
  # @note: Properties other than `providedLabel` are retained by the original 
  #   node. This does not attempt to keep like properties together.
  # @note: Nodes created by this enrichment share a class with the original 
  #   input value.
  #
  # @example
  #   label_splitter = SplitOnProvidedLabel.new
  #   node = DPLA::MAP::Agent.new(providedLabel: ['moomin', 'moominmama']
  #                               closeMatch:    'Moomintroll')
  #
  #   new_values = label_splitter.enrich_value(node)
  #   new_values # => [#<DPLA::MAP::Agent:0x1...()>,
  #                    #<DPLA::MAP::Agent:0x2...()>]
  # 
  #   new_values.map(&:providedLabel) # => [['moomin'], ['moominmama']]
  #
  # @see Audumbla::FieldEnrichment
  class SplitOnProvidedLabel
    include Audumbla::FieldEnrichment

    ##
    # @param value [Object] the value to split
    # @see Audumbla::FieldEnrichment#enrich_value
    def enrich_value(value)
      return value unless value.is_a?(ActiveTriples::Resource) &&
                          value.respond_to?(:providedLabel)
      return value unless value.providedLabel.count > 1
      split_provided(value)
    end

    private

    ##
    # @param value [ActiveTriples::Resource] a resource with one or more
    #   `providedLabels`.
    # @return [Array<ActiveTriples::Resource] an array on resources matching the
    #   class of the original; the array contains the original resource, reduced
    #   to one `providedLabel`, and a resource for each extra label.
    def split_provided(value)
      labels = value.providedLabel.dup
      value.providedLabel = labels.shift

      nodes = [value]

      labels.each_with_object(nodes) do |label, object|
        new_node               = value.class.new
        new_node.providedLabel = label
        nodes << new_node
      end
    end
  end
end
