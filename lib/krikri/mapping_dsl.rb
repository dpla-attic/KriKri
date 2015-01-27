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

    DCMITYPE_LABELS = RDF::DCMITYPE.select(&:class?).map { |t| t.label.downcase }

    # TODO: Discuss with Content Team. `dpla_map` currently constrains
    # genre (edm:hasType) to AAT terms; these are not all AAT terms.
    GENRE_LABELS = ['book', 'film/video', 'manuscript', 'maps', 'music',
                    'musical score', 'newspapers', 'nonmusic',
                    'photograph/pictorial works', 'serial']

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
