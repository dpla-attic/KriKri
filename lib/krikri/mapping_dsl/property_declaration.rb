module Krikri::MappingDSL
  ##
  # Specifies a mapping between a property name and its mapped value(s).
  # Deals with static properties (given a specific value or values), and
  # dynamic properties (where values are modified by a block).
  class PropertyDeclaration
    attr_reader :name, :value

    def initialize(name, value, _opts = {}, &block)
      if block_given?
        raise 'Block must have arity of 1 to be applied to property' unless
          block.arity == 1
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
    # property.
    def to_proc
      block = @block if @block
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

    def setter
      "#{@name}=".to_sym
    end
  end
end
