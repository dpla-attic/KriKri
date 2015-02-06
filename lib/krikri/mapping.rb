module Krikri
  ##
  # Handles transformation of OriginalRecords into a target class.
  #
  #   map = Mapping.new(MyModelClass)
  #   map.dsl_method args
  #   map.process_record(my_original_record)
  #   # => #<MyModelClass:0x3ff8b7459210()>
  #
  class Mapping
    include MappingDSL

    attr_reader :klass, :parser, :parser_args

    ##
    # @param klass [Class] The model class to build in the mapping process.
    # @param parser [Class] The parser class with which to process resources.
    # @param parser_args [Array] The arguments to pass to the parser when
    #   processing records.
    def initialize(klass = DPLA::MAP::Aggregation,
                   parser = Krikri::XmlParser,
                   *parser_args)
      @klass = klass
      @parser = parser
      @parser_args = parser_args
    end

    ##
    # @param record [OriginalRecord] An original record to process.
    # @return [Object] A model object of type @klass, processed through the
    #   mapping DSL
    def process_record(record)
      mapped_record = klass.new
      properties.each do |prop|
        prop.to_proc.call(mapped_record, parser.parse(record, *@parser_args))
      end
      mapped_record
    end
  end
end
