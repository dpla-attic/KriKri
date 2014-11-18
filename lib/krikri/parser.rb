module Krikri
  ##
  # Provides a generic interface for accessing properties from OriginalRecords.
  # Implement the interface, and that of `Value` on an record-type basis.
  #
  #   parser = Krikri::Parser::MyParser.new(record)
  #   parser.root # => #<Krikri::MyParser::Value:0x007f861888fea0>
  #
  class Parser
    attr_reader :root, :record

    ##
    # @param record [Krikri::OriginalRecord] a record whose properties can
    #   be parsed by the parser instance.
    def initialize(record)
      @record = record
    end

    ##
    # A generic parser value.
    #
    # Interface to a single value node which can access typed data values (e.g.
    # String, DateTime, etc...) parsed from a string, and provides access to
    # child nodes and attributes.
    class Value
      ##
      # Property accessor interface. Passes `name` to the local implementation
      # of #get_child_nodes.
      #
      # @param name [#to_sym] a named property to access
      def [](name)
        get_child_nodes(name)
      end

      ##
      # Queries whether `name` is a subproperty of this node
      # @param name [#to_sym] a named property to query
      # @return [Boolean] true if `name` is a subproperty of the current node
      def child?(name)
        children.include?(name)
      end

      ##
      # @abstract
      # @return [Array<Symbol>] a list of subproperties that can be passed back
      #   to #[] to access child nodes
      def children
        raise NotImplementedError
      end

      ##
      # @abstract
      # @return [<#to_s>] typed value for the property
      def value
        raise NotImplementedError
      end

      ##
      # @abstract
      # @return [Boolean] true if this node has typed values accessible with
      #   #values
      def values?
        raise NotImplementedError
      end

      ##
      # @abstract
      # @return [Array<Symbol>] a list of attributes accessible on the node
      def attributes
        raise NotImplementedError
      end

      ##
      # Queries whether `name` is an attribute of this node
      # @param name [#to_sym] an attribute name to query
      # @return [Boolean] true if `name` is an attribute of the current node
      def attribute?(name)
        attributes.include?(name)
      end

      def method_missing(name, *args, &block)
        return attribute(name) if attribute?(name)
        super
      end

      def respond_to_missing(method, *)
        attribute?(method) || super
      end

      private

      ##
      # @abstract
      def attribute(name)
        raise NotImplementedError, "Can't access attribute #{name}"
      end

      ##
      # @abstract Provide an accessor for properties
      # @param name [#to_sym] a named property to access
      # @return [Krikri::Parser::Value] the value of the child node
      def get_child_nodes(name)
        raise NotImplementedError, "Can't access property #{name}"
      end
    end
  end
end
