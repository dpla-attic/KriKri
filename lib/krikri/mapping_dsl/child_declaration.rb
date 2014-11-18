module Krikri::MappingDSL
  ##
  # Returns a proc that can be run to add values for the property to
  # Passes value(s) through a block, if given.
  # @return [Proc] a proc that can be used to generate a value for the named
  # property.
  class ChildDeclaration < PropertyDeclaration
    def initialize(name, target_class, &block)
      @name = name
      @target_class = target_class
      @block = block
    end

    def to_proc
      block = @block if @block
      target_class = @target_class
      lambda do |target, record|
        map = ::Krikri::Mapping.new(target_class)
        map.instance_eval(&block)
        target.send(setter, map.process_record(record))
      end
    end
  end
end
