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
    # @return [String] the local_name of the OriginalRecord wrapped by this
    #   parser
    def local_name
      record.local_name
    end

    ##
    # A generic parser value.
    #
    # Interface to a single value node which can access typed data values (e.g.
    # String, DateTime, etc...) parsed from a string, and provides access to
    # child nodes and attributes.
    class Value
      ##
      # Property accessor interface. Passes a name expression (`name_exp`) to
      # the local implementation of #get_child_nodes.
      #
      # The given name expression must follow the pattern:
      #     name [| name ...]
      #
      # The optional "|" is a short-circuit operator that will return the
      # property or element in the document for the first matching part of the
      # phrase.
      #
      # @example
      #   va = value['title']
      #   va = value['this|that']  # gives value for "this" if both defined
      #
      # @param name [String] An expression of named properties to access
      # @return [Krikri::Parser::ValueArray]
      def [](name_exp)
        name_exp.strip.split(/\s*\|\s*/).each do |n|
          result = get_child_nodes(n)
          return result unless result.empty?
        end
        Krikri::Parser::ValueArray.new([])
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
      # @abstract Return a Krikri::Parser::ValueArray of child nodes
      #
      # @param name [String] Element or property name
      # @return [Krikri::Parser::ValueArray] The child nodes
      def get_child_nodes(name)
        raise NotImplementedError, "Can't access property #{name}"
      end
    end

    ##
    # A specialized Array object for containing Parser::Values. Provides methods
    # for accessing and filtering values that can be chained.
    #
    # @example chaining methods to select values
    #
    #     my_value_array.field('dc:creator', 'foaf:name')
    #       .match_attribute('first_name').values
    #
    # Methods defined on this class should return another ValueArray, an Array
    # of literal values (retrieved from Parser::Value#value), or a single
    # literal value.
    #
    # Uses `@bindings` to track variables for recovery via `#else`, `#from`, and
    #`#back`. Methods that return a `ValueArray` should pass `@bindings` down to
    # the new instance.
    #
    # @example `#if` sets `@bindings[:top]`, `#else` recoveres if empty
    #
    #   my_value_array.field('dc:creator', 'foaf:name').if.field('empty:field')
    #     .else { |vs| vs.field('some:otherField') }
    #
    class ValueArray
      include Enumerable

      delegate :[], :each, :empty?, :to_a, :to_ary,
         :to => :@array

      ##
      # @param array [Array] an array of values to delegate array operations to
      # @param bindings [Hash<Symbol, ValueArray] a set of variable bindings
      #   This is overloaded to accept an instance of this class to use as a 
      #   `:top` recovery node in, e.g. `#else`. `:top` to `self` if none is
      #   passed.
      def initialize(array = [], bindings = {})
        @array = array

        if bindings.is_a?(ValueArray)
          # this way is deprected!
          # how should we handle deprecations?
          @bindings = {}
          @bindings[:top] ||= bindings
        else
          @bindings = bindings
          @bindings[:top] ||= self
        end
      end

      ##
      # @see Array#[]=
      # @raise [InvalidParserValueError] when the value is not a Parser::Value
      def []=(index, value)
        raise InvalidParserValueError unless value.is_a? Value
        @array[index] = value
        self
      end

      ##
      # @see Array#<<
      # @raise [InvalidParserValueError] when the value is not a Parser::Value
      def <<(value)
        raise InvalidParserValueError unless value.is_a? Value
        @array << value
        value
      end

      ##
      # @see Array#concat
      # @return [ValueArray]
      def concat(*args, &block)
        self.class.new(@array.concat(*args, &block), @bindings)
      end

      ##
      # @return [Array] literal values from the objects in this array.
      # @see Parser::Value#value
      def values
        @array.map { |v| v.respond_to?(:value) ? v.value : v }
      end

      ##
      # @param idx [#to_i, Range]
      # @return [ValueArray] an array containing the node(s) in the 
      #   specified index posiition(s).
      def at(idx)
        self.class.new(Array(@array[idx]))
      end

      ##
      # Accesses a given field. Use multiple arguments to travel down the node
      # hierarchy.
      #
      # @return [ValueArray] an array containing the nodes available in a
      #   particular field.
      def field(*args)
        result = self
        args.each { |name| result = result.get_field(name) }

        result
      end

      ##
      # Accesses the union of multiple specified fields.
      #
      # @return [ValueArray] an array containing the nodes available in the
      # given fields.
      def fields(*args)
        results = args.map do |f|
          field(*Array(f))
        end
        self.class.new(results.flatten, @bindings)
      end

      ##
      # Sets the top of the call chain to self and returns or yields self
      #
      # @example with method chain syntax
      #   value_array.if.field(:a_field).else do |arry|
      #      arry.field(:alternate_field)
      #   end
      #
      # @example with block syntax
      #   value_array.if { |arry| arry.field(:a_field) }
      #     .else { |arry|  arry.field(:alternate_field) }
      #
      # @yield gives self
      # @yieldparam arry [ValueArray] self
      #
      # @return [ValueArray] the result of the block, if given; or self with @top set
      def if(&block)
        @bindings[:top] = self
        return yield self if block_given?
        self
      end

      ##
      # Short circuits if `self` is not empty, else passes the top of the call
      # chain (`@bindings[:top]`) to the given block.
      #
      # @example usage with `#if`
      #   value_array.if { |arry| arry.field(:a_field) }
      #     .else { |arry|  arry.field(:alternate_field) }
      #
      #   # use other filters at will
      #   value_array.if.field(:a_field).reject { |v| v == 'SKIP ME' }
      #     .else { |arry|  arry.field(:alternate_field) }
      #
      # @example standalone use; resetting to record root
      #   value_array.field(:a_field).else { |arry| arry.field(:alternate_field) }
      #
      # @yield gives `@bindings[:top]` if self is empty
      # @yieldparam arry [ValueArray] the value of `@bindings[:top]`
      #
      # @return [ValueArray] `self` unless empty; otherwise the result of the
      #   block
      def else(&block)
        raise ArgumentError, 'No block given for `#else`' unless block_given?
        return self unless self.empty?
        yield @bindings[:top]
      end

      ##
      # Retrieves the first element of a ValueArray. Uses an optional argument
      # to specify how many items to return. By design, it behaves similarly
      # to Array#first, but it intentionally doesn't override it.
      #
      # @return [ValueArray] a Krikri::Parser::ValueArray for first n elements
      def first_value(*args)
        return self.class.new(@array.first(*args)) unless args.empty?
        self.class.new([@array.first].compact, @bindings)
      end

      ##
      # Retrieves the last element of a ValueArray. Uses an optional argument
      # to specify how many items to return. By design, it behaves similarly
      # to Array#last, but it intentionally doesn't override it.
      #
      # @return [ValueArray] a Krikri::Parser::ValueArray for last n elements
      def last_value(*args)
        return self.class.new(@array.last(*args)) unless args.empty?
        self.class.new([@array.last].compact, @bindings)
      end

      ##
      # @see Array#compact
      # @return [ValueArray]
      def compact
        self.class.new(@array.compact, @top)
      end

      ##
      # @see Array#concat
      # @return [ValueArray]
      def flatten(*args, &block)
        self.class.new(@array.flatten(*args, &block), @bindings)
      end

      ##
      # Wraps the result of Array#map in a ValueArray
      #
      # @see Array#map
      # @return [ValueArray]
      def map(*args, &block)
        self.class.new(@array.map(*args, &block), @bindings)
      end

      ##
      # Wraps the result of Array#select in a ValueArray
      #
      # @see Array#select
      # @return [ValueArray]
      def select(*args, &block)
        self.class.new(@array.select(*args, &block), @bindings)
      end

      ##
      # Wraps the result of Array#reject in a ValueArray
      #
      # @see Array#reject
      # @return [ValueArray]
      def reject(*args, &block)
        self.class.new(@array.reject(*args, &block), @bindings)
      end

      ##
      # @example selecting by presence of an attribute; returns all nodes where
      #   `#attribute?(:type)` is true
      #
      #   match_attribute(:type)
      #
      # @example selecting by the value of an attribute; returns all nodes with
      #   `#attribute(:type) == other`
      #
      #   match_attribute(:type, other)
      #
      # @example selecting by block against an attribute; returns all nodes with
      #   `block.call(attribute(:type))` is true
      #
      #   match_attribute(:type) { |value| value.starts_with? 'blah' }
      #
      # @example selecting by block against an attribute; returns all nodes with
      #   `block.call(attribute(:type)) == other` is true
      #
      #   match_attribute(:type, 'moomin') { |value| value.downcase }
      #
      # @param name [#to_sym] an attribute name
      # @param other [Object] an object to check for equality with the
      #   values from the given attribute.
      #
      # @yield [value] yields each value with the attribute in name to the block
      #
      # @return [ValueArray] an array containing nodes for which the specified
      #   attribute has a value matching the given attribute name, object, and
      #   block.
      def match_attribute(name, other = nil, &block)
        select(&compare_to_attribute(name, other, &block))
      end

      ##
      # @param name [#to_sym] an attribute name
      # @param other [Object] an object to check for equality with the
      #   values from the given attribute.
      #
      # @yield [value] yields each value with the attribute in name to the block
      #
      # @return [ValueArray] an array containing nodes for which the specified
      #   attribute does not have a value matching the given attribute name,
      #   object, and block.
      #
      # @see #match_attribute  for examples; this calls #reject, where it calls
      #   #select.
      def reject_attribute(name, other = nil, &block)
        reject(&compare_to_attribute(name, other, &block))
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
        self.class.new(flat_map { |val| val[name] }, @bindings)
      end

      private

      ##
      # @see #match_attribute, #reject_attribute
      def compare_to_attribute(name, other, &block)
        lambda do |v|
          next unless v.attribute?(name.to_sym)
          result = v.send(name)
          result = yield(result) if block_given?
          return result == other if other
          result
        end
      end

      public

      class InvalidParserValueError < TypeError; end
    end
  end
end
