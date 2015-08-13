module Krikri::MappingDSL
  ##
  # Returns a proc that can be run to add values for the property to
  # Passes value(s) through a block, if given.
  # @return [Proc] a proc that can be used to generate a value for the named
  # property.
  class ChildDeclaration < PropertyDeclaration
    def initialize(name, target_class, opts = {}, &block)
      @name = name
      @target_class = target_class
      @block = block
      @each = opts.delete(:each)
      @as = opts.delete(:as)
    end

    def to_proc
      block = @block if @block
      target_class = @target_class
      each_val = @each
      as_sym = @as
      lambda do |target, record|
        if each_val
          each_val.call(record).each do |value|
            map = ::Krikri::Mapping.new(target_class)
            map.define_singleton_method(as_sym) do
              each_val.dup.select do |v|
                v = v.value if v.respond_to? :value
                v == value 
              end
            end
            map.instance_eval(&block)
            target.send(name) << map.process_record(record)
          end
        else
          map = ::Krikri::Mapping.new(target_class)
          map.instance_eval(&block)
          target.send(setter, map.process_record(record))
        end
      end
    end
  end
end
