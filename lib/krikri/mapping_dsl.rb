require 'krikri/mapping_dsl/property_declaration'
require 'krikri/mapping_dsl/child_declaration'
require 'krikri/mapping_dsl/parser_methods'
require 'krikri/mapping_dsl/rdf_subjects'

module Krikri
  ##
  # Mixin implementing DSL methods for metadata mapping. The main MappingDSL
  # module implements the core property definition methods, while nested modules
  # add various extensions.
  module MappingDSL
    extend ActiveSupport::Concern
    include ParserMethods
    include RdfSubjects

    ##
    # List the property and child declarations set on mapping.
    #
    # @return [Array<PropertyDeclaration, ChildDeclaration>]
    def properties
      @properties ||= []
    end
    
    ##
    # @return [true]
    # @see #method_missing
    def respond_to_missing?(*)
      true
    end
    
    ##
    # The class responds to all methods; treating any not defined as 
    # property/child declarations.
    # 
    # @return [PropertyDeclaration, ChildDeclaration]
    def method_missing(name, *args, &block)
      return add_child(name, *args, &block) if block && block.arity == 0
      add_property(name, *args, &block)
    end

    private

    ##
    # Add a ChildDeclaration to this mapping
    #
    # @param [Symbol] name
    # @param [Hash] opts accepts options; expected options: :class
    #
    # @return [ChildDeclaration]
    def add_child(name, opts = {}, &block)
      delete_property(name)
      properties << ChildDeclaration.new(name, opts.delete(:class), opts, &block)
    end

    ##
    # Add a PropertyDeclaration to this mapping
    #
    # @param [Symbol] name
    # @param [Hash] value ; defaults to nil
    #
    # @return [ChildDeclaration]
    def add_property(name, value = nil, &block)
      delete_property(name)
      properties << PropertyDeclaration.new(name, value, &block)
    end

    ##
    # Remove a declaration from the property list
    #
    # @param [Symbol] name  the name property whose declarations to remove
    def delete_property(name)
      properties.delete_if { |prop| prop.name == name }
    end
  end
end
