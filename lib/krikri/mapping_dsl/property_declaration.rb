module Krikri::MappingDSL
  ##
  # Specifies a mapping between a property name and its mapped value(s).
  # Deals with static properties (given a specific value or values), and
  # dynamic properties (where values are modified by a block).
  #
  # @example a basic declaration
  #   class Book; attr_accessor :author; end
  #
  #   dec = Krikri::MappingDSL::PropertyDeclaration.new(:author, 
  #     ['Moomin', 'Snuffkin'])
  #
  #   book = Book.new
  #   dec.to_proc.call(book, nil) # nil stands in for a record.
  #   
  #   book.author # => ['Moomin', 'Snuffkin']
  #
  #
  # @example a declaration with a callable value
  #   class Book; attr_accessor :author; end
  #
  #   values = lambda { |_| ['Moomin', 'Snuffkin'] }
  #   dec = Krikri::MappingDSL::PropertyDeclaration.new(:author, values)
  #
  #   book = Book.new
  #   dec.to_proc.call(book, nil) # nil stands in for a record.
  #   
  #   book.author # => ['Moomin', 'Snuffkin']
  #   
  class PropertyDeclaration
    attr_reader :name, :value

    ##
    # Initializes a declaration with a given name and value. `value` may 
    # respond to `#call`, which will be called with a record to generate the
    # values.
    #
    # @param name  [Symbol]
    # @param value [#call, Object] 
    # @param _opts [Hash] A hash of options for for the declaration. default: {}
    #
    # @raise ArgumentError  when a block with arity other than 1 is passed
    def initialize(name, value, _opts = {}, &block)
      if block_given?
        unless block.arity == 1
          raise(ArgumentError, 
                'Block must have arity of 1 to be applied to property')
        end
        @block = block
      end

      @name = name
      @value = value
    end

    ##
    # Returns a proc that can be run to add values for the property to
    # Passes value(s) through a block, if given.
    #
    # If value is a callable object (e.g. a Proc), calls it with the
    # OriginalRecord as an argument to determine the value.
    #
    # @return [Proc] a proc that can be used to generate a value for the named
    #   property.
    def to_proc
      block = @block
      value = @value
      
      lambda do |target, record|
        value = value.call(record) if value.respond_to? :call
        return target.send(setter, value) unless block

        if value.is_a? Enumerable
          values = value.map { |v| instance_exec(v, &block) }
          target.send(setter, values)
        else
          target.send(setter, instance_exec(value, &block))
        end
      end
    end

    private

    ##
    # @return [Symbol] A symbol for the setter method; e.g. `:name=`
    def setter
      "#{@name}=".to_sym
    end
  end
end
