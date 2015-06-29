module Krikri
  ##
  # An XmlParser
  # @see Krikri::Parser
  class XmlParser < Krikri::Parser
    ##
    # @param record [Krikri::OriginalRecord] a record whose properties can
    # be parsed by the parser instance.
    # @param root_path [String] XPath that identifies the root path for
    # the desired parse root.
    # @param ns [Hash] A hash containing namespaces to identify up front.
    # For each hash item, the key refers to the prefix used, and its value
    # is the associated namespace URI.
    def initialize(record, root_path = '/', ns = {})
      xml = Nokogiri::XML(record.to_s)
      ns = namespaces_from_xml(xml).merge(ns)
      root_node = xml.at_xpath(root_path, ns) 
      raise EmptyRootNodeError if root_node.nil?
      @root = Value.new(root_node, ns)
      super(record)
    end

    private

    def namespaces_from_xml(xml)
      namespaces = xml.collect_namespaces.map do |k, v|
        [k.gsub('xmlns:', ''), v]
      end
      namespaces.to_h
    end

    ##
    # An XML Parser Value node class
    # @see Krikri::Parser::Value
    class Value < Krikri::Parser::Value
      attr_accessor :node, :namespaces
      delegate :xpath, :at_xpath, :css, :at_css, :to => :@node

      def initialize(node, namespaces)
        node = node.root if node.xml?
        @node = node
        @namespaces = namespaces
      end

      def attributes
        @node.attributes.keys.map(&:to_sym)
      end

      def children
        @node.element_children.map do |child|
          return child.name unless child.namespace
          "#{@namespaces.key(child.namespace.href)}:#{child.name}"
        end
      end

      def value
        @node.content
      end

      def values?
        !select_values.empty?
      end

      private

      ##
      # @see Krikri::Parser#get_child_nodes
      #
      # @param name_exp [String]  Element name
      # @return [Krikri::Parser::ValueArray]
      def get_child_nodes(name)
        Krikri::Parser::ValueArray.new(
          @node.xpath("#{@node.path}/#{name}", @namespaces)
            .map { |node| self.class.new(node, @namespaces) }
        )
      end

      def attribute(name)
        @node.attributes[name.to_s].value
      end

      def select_values
        Krikri::Parser::ValueArray.new(@node.children.select(&:text?))
      end
    end
    
    ##
    # An error class for empty Value nodes.
    #
    # This is raised if a root value does not exist.
    class EmptyRootNodeError < ArgumentError; end
  end
end
