module Krikri
  ##
  # Handles transformation of OriginalRecords into a target class.
  #
  # @example 
  #    map = Mapping.new(MyModelClass)
  #    map.dsl_method args
  #    map.process_record(my_original_record)
  #    # => #<MyModelClass:0x3ff8b7459210()>
  #
  # When one or more errors are encoutered during processing, they are collected
  # in a `Krikri::Kapping::Error` and re-raised.
  #
  # @example When an error is thrown during property mapping
  #    map = Mapping.new(MyModelClass)
  #    begin
  #      map.process_record(my_original_record)
  #    rescue Mapping::Error => e
  #      e.message
  #    end
  #    # => Property failed on subject:
  #    #       {subject error message}
  #    #       {subject error backtrace}
  #    #    Property failed on title:
  #    #       {title error message}
  #    #       {title error backtrace}
  #   
  # @see Krikri::MappingDSL
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
    #
    # @return [Object] A model object of type @klass, processed through the
    #   mapping DSL
    # @raise [Krikri::Mapper::Error] when an error is thrown when handling any
    #   of the properties
    def process_record(record)

      #
      # MEMORY PROFILING
      #

      m_before = GetProcessMem.new.mb

      mapped_record = klass.new
      error = properties.each_with_object(Error.new(record)) do |prop, error|
        begin
          prop.to_proc.call(mapped_record, parser.parse(record, *@parser_args))
        rescue => e
          error.add(prop.name, e)
        end
      end
      raise error unless error.errors.empty?

      m_after = GetProcessMem.new.mb

      Krikri::StatCounter.add(:process_record, m_after - m_before)

      mapped_record
    end
    
    ##
    # An error class for exceptions thrown during `Krikri::Mapping` processes.
    #
    # Collects the full set of errors encountered when mapping a given record,
    # along with the property names that were being processed when throwing the 
    # error.
    #
    # @example collecting exceptions and reraising
    #   err = Krikri::Mapping::Error.new(record)
    #   err.add(:title, exception)
    #   raise err
    #
    class Error < RuntimeError
      attr_accessor :original_record, :errors

      ##
      # @param [Krikri::OriginalRecord] record
      def initialize(record)
        @original_record = record
        @errors = {}
      end

      ##
      # @param [Symbol] property  the name of the property for the error
      # @param [Exception] parent_error  the error to add
      def add(property, parent_error)
        errors[property] = parent_error
      end

      ##
      # @return [Array<Symbol>] the property names that caused errors
      def properties
        errors.keys
      end
      
      ##
      # @return [String] a message describing the full error set
      def message
        msg = "Error processing mapping for #{original_record.local_name}\n"
        errors.each do |property, error|
          msg << "Failed on property #{property}:\n"
          msg << "\t#{error.message}\n\t#{error.backtrace.join("\n\t")}"
        end

        msg
      end
    end
  end
end
