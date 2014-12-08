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
    extend SoftwareAgent
    include MappingDSL

    ##
    # @param klass [Class] The model class to build in the mapping process.
    def initialize(klass = DPLA::MAP::Aggregation)
      @klass = klass
    end

    ##
    # @param record [OriginalRecord] An original record to process.
    # @return [Object] A model object of type @klass, processed through the
    #   mapping DSL
    def process_record(record)
      mapped_record = @klass.new
      properties.each do |prop|
        prop.to_proc.call(mapped_record, record)
      end
      mapped_record
    end
  end
end
