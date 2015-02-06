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
    # Instantiates a parser object to wrap the record. Returns the record
    # as is if it is already parsed.
    #
    # @param record [Krikri::OriginalRecord, Krikri::Parser] the record to parse
    # @param args [Array, nil] the arguments to pass to the parser instance,
    #   if any
    # @return [Krikri::Parser] a parsed record object
    def self.parse(record, *args)
      record.is_a?(Krikri::Parser) ? record : new(record, *args)
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
        begin
          attributes.include?(name)
        rescue NotImplementedError
          false
        end
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

    ##
    # A specialized Array object for containing Parser::Values. Provides methods
    # for accessing and filtering values that can be chained.
    #
    #     my_value_array.field('dc:creator', 'foaf:name')
    #       .match_attribute('first_name').values
    #
    # Methods defined on this class should return another ValueArray, an Array
    # of literal values (retrieved from Parser::Value#value), or a single
    # literal value.
    class ValueArray
      include Enumerable

      delegate :<<, :[], :[]=, :each, :empty?, :map, :to_a, :to_ary,
      :to => :@array

      def initialize(array = [])
        @array = array
      end

      ##
      # @return [Array] literal values from the objects in this array.
      # @see Parser::Value#value
      def values
        map(&:value)
      end

      ##
      # Accesses a given field. Use multiple arguments to travel down the node
      # hierarchy.
      #
      # @return [ValueArray] an array containing the nodes available in a
      #   particular field.
      def field(*args)
        result = self
        args.each do |name|
          result = result.get_field(name)
        end
        result
      end

      ##
      # Retrieves the first element of a ValueArray. Uses an optional argument
      # to specify how many items to return. By design, it behaves similarly
      # to Array#first, but it intentionally doesn't override it.
      #
      # @return [ValueArray] a Krikri::Parser::ValueArray for first n elements
      def first_value(*args)
        return self.class.new(@array.first(*args)) unless args.empty?
        self.class.new([@array.first].compact)
      end

      ##
      # Wraps the result of Array#select in a ValueArray
      #
      # @see Array#select
      def select(*args, &block)
        self.class.new(@array.select(*args, &block))
      end

      ##
      # Wraps the result of Array#reject in a ValueArray
      #
      # @see Array#reject
      def reject(*args, &block)
        self.class.new(@array.reject(*args, &block))
      end

      ##
      # @param name [#to_sym] an attribute name
      # @param other [Object] an object to for equality with the
      #   values from the given attribute.
      #
      # @return [ValueArray] an array containing nodes for which the specified
      #   attribute has a value matching the given object.
      def match_attribute(name, other)
        select do |v|
          next unless v.attribute?(name.to_sym)
          v.send(name).downcase == other.downcase
        end
      end

      ##
      # Wraps the root node of the given record in this class.
      #
      # @param record [Krikri::Parser] a parsed record to wrap in a ValueArray
      # @return [ValueArray]
      def self.build(record)
        new([record.root])
      end

      protected

      def get_field(name)
        self.class.new(flat_map { |val| val[name] })
      end
    end
  end
end
