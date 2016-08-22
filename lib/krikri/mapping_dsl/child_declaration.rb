module Krikri::MappingDSL
  ##
  # Specifies a mapping between a property and one or more child nodes.
  #
  # The child node is built by processing a sub-mapping, generating an object 
  # that can be set to the property. 
  #
  # Multiple sub-mappings can be processed with, the `:each` and `:as` options. 
  # When given, the sub-mapping is run once for each value given to `:each`, with
  # the variable `:as` passed to.
  # 
  # @example a basic declaration
  #   class Book; attr_accessor :author; end
  #   class Agent; attr_accessor :name, :locale; end
  #
  #   dec = Krikri::MappingDSL::ChildDeclaration.new(:author, Agent) do
  #     name   'Moomin'
  #     locale 'Moomin Valley'
  #   end
  #
  #   book = Book.new
  #   dec.to_proc.call(book, nil) # nil stands in for a record.
  #   book.author
  #   # => #<Agent:0x0055654f5d5138 @locale="Moomin Valley", @name="Moomin">
  #
  # @example an :each/:as declaration
  #   class Book; attr_accessor :author; end
  #   class Agent; attr_accessor :name, :locale; end
  #
  #   dec = Krikri::MappingDSL::ChildDeclaration.new(:author, Agent,
  #       each: ['Moomin', 'Snuffkin'], as: :agent_name) do
  #     name    agent_name
  #     locale 'Moomin Valley'
  #   end
  #
  #   book = Book.new.tap { |b| b.author = [] }
  #   dec.to_proc.call(book, nil)
  #   book.author
  #   # => [#<Agent:0x0055654f405808
  #   #   @locale="Moomin Valley",
  #   #   @name="Moomin">,
  #   #  #<Agent:0x0055654f4040c0
  #   #   @locale="Moomin Valley",
  #   #   @name="Snuffkin">]
  #
  # @see PropertyDeclaration for more information about how values that respond 
  #   to `#call` are processed.
  class ChildDeclaration < PropertyDeclaration
    ##
    # @param name [Symbol]  a symbol representing the property to set the child
    #   node(s) to.
    # @param  target_class [#call, Object] the class to use when building child 
    #   mappings. Values set through a ChildDeclartaion will be instances of 
    #   this class
    #
    # @param  opts [Hash]
    # @option opts [#call, Enumerable] :each  the values to bind to 
    # @option opts [Symbol] :as  the "variable" to bind the values of `:each`
    #   to within the child Mapping's scope
    def initialize(name, target_class, opts = {}, &block)
      @name         = name
      @target_class = target_class
      @block        = block
      @each         = opts.delete(:each)
      @as           = opts.delete(:as)
    end

    ##
    # Returns a proc that can be run to create one or more child node as 
    # instances of the `target_class`. Each node is evaluated as a sub-mapping
    # with the block given. The values of `:each` are available within the 
    # block's scope.
    #
    # @return [Proc] a callable proc that evaluates the sub-mappings
    def to_proc
      block        = @block
      target_class = @target_class
      each_val     = @each
      as_sym       = @as
      
      lambda do |target, record|
        # if `@each` is set, iterate through its values and process the mapping for each.
        # this results in a different child record/node for each value in `@each`.
        if each_val
          iter = each_val.respond_to?(:call) ? each_val.call(record) : each_val
          iter.each do |value|
            map = Krikri::Mapping.new(target_class)

            # define as_sym to return the node (not the value) for this value, 
            # only on this instance
            map.define_singleton_method(as_sym) do
              each_val.dup.select do |v|
                v = v.value if v.respond_to? :value
                v == value
              end
            end

            map.instance_eval(&block)
            target.send(name) << map.process_record(record)
          end
        # else, process a single child mapping over a single instance of 
        # `target_class`
        else
          map = Krikri::Mapping.new(target_class)
          map.instance_eval(&block)
          target.send(setter, map.process_record(record))
        end
      end
    end
  end
end
