require 'krikri/mapping_dsl/property_declaration'
require 'krikri/mapping_dsl/child_declaration'
require 'krikri/mapping_dsl/parser_methods'

module Krikri
  ##
  # Mixin implementing DSL methods for metadata mapping. The main MappingDSL
  # module implements the core property definition methods, while nested modules
  # add various extensions.
  module MappingDSL
    extend ActiveSupport::Concern
    include ParserMethods

    def properties
      @properties ||= []
    end

    def respond_to_missing?(*)
      true
    end

    def method_missing(name, *args, &block)
      return add_child(name, *args, &block) if block && block.arity == 0
      add_property(name, *args, &block)
    end

    private

    def add_child(name, opts = {}, &block)
      delete_property(name)
      properties << ChildDeclaration.new(name, opts.fetch(:class), &block)
    end

    def add_property(name, value = nil, &block)
      delete_property(name)
      properties << PropertyDeclaration.new(name, value, &block)
    end

    def delete_property(name)
      properties.delete_if { |prop| prop.name == name }
    end
  end
end
