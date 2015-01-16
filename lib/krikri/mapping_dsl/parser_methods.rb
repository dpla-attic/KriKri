module Krikri::MappingDSL
  ##
  # Implements methods for accessing parsed values in MappingDSL
  module ParserMethods
    extend ActiveSupport::Concern

    ##
    # Gives access to delayed method calls on parsed record ValueArrays, to
    # be executed at the time the mapping is processed.
    #
    # @return [RecordProxy] a RecordProxy providing delayed method calls against
    #   a parsed record.
    # @see Krikri::MappingDSL::ParserMethods::RecordProxy
    def record
      RecordProxy.new
    end

    ##
    # Gives access to a delayed call for the `#local_name` of an OriginalRecord,
    # to be executed at the time the mapping is processed.
    #
    # @return [Proc] a proc that, when called, returns the #local_name of the
    #   OriginalRecord associated with the parsed record passed as its argument.
    def local_name
      lambda do |parsed|
        parsed.record.local_name
      end
    end

    ##
    # Gives access to a delayed call for the `#rdf_subject` of an
    # OriginalRecord, to be executed at the time the mapping is processed.
    #
    # @return [Proc] a proc that, when called, returns the #rdf_subject of the
    #   OriginalRecord associated with the parsed record passed as its argument.
    def record_uri
      lambda do |parsed|
        parsed.record.rdf_subject
      end
    end

    ##
    # This class acts as a proxy for a parsed record's nodes, wrapped in the
    # class passed as the second argument. All methods available on the wrapper
    # class are accepted via #method_missing, added to the #call_chain, and
    # return `self`, allowing chained method calls.
    #
    #   record.field('dct:title').field('foaf:name')
    #
    # @see Krikri::Parser::ValueArray
    class RecordProxy
      attr_reader :value_class, :call_chain

      ##
      # Create a new RecordProxy object.
      #
      # @param call_chain [Array<Hash>] an array of hashes representing method
      #   calls. Hashes need a :name (method name), :args (array of arguments),
      #   and :block (a Proc to pass as a block). Defaults to [].
      # @param klass [Class] a Class that acts as the target for delayed method
      #   calls. Must respond to #build(record) and #values. Defaults to
      #   Krikri::Parser::ValueArray
      #
      # @return [RecordProxy]
      def initialize(call_chain = [], klass = Krikri::Parser::ValueArray)
        @call_chain = call_chain
        @value_class = klass
      end

      def dup
        RecordProxy.new(call_chain.dup, value_class)
      end

      ##
      # Wraps a given record in #value_class and applies the call chain;
      # each method is sent to the result of the previous method. Finally,
      # calls #values on the result.
      #
      # @param record A parsed record object (e.g. Krikri::Parser) to be sent to
      #   value_class#build.
      # @return the values resulting from the full run of the call chain
      def call(record)
        result = value_class.build(record)
        call_chain.each do |message|
          result = result.send(message[:name], *message[:args], &message[:block])
        end
        result.values
      end

      ##
      # @return [Integer] the arity of self#call
      # @see #call
      def arity
        1
      end

      ##
      # Adds method to the call chain if it is a valid method for value_class.
      #
      # @return [RecordProxy] self, after adding the method to the call chain
      #
      # @raise [NoMethodError] when the method is unavailable on #value_class.
      # @raise [ArgumentError] when the arity of the call does not match the
      #   method on #value_class
      def method_missing(name, *args, &block)
        super unless respond_to? name

        arity = value_class.instance_method(name).arity
        raise ArgumentError, "Method #{name} called with #{args.length} " \
        "arguments, expected #{arity}." unless arity < 0 || args.length == arity

        call_chain << { name: name, args: args, block: block }
        self
      end

      def respond_to?(name)
        value_class.instance_methods.include?(name) || super
      end
    end
  end
end
