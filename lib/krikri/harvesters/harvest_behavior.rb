module Krikri::Harvesters
  ##
  # Defines an interface for handling records during the harvest process.
  # Subclasses specify behavior by implementing `#process_record`.
  #
  # Behaviors should be implemented idempotently so they can be safely
  # retried on errors.
  #
  # @example
  #   behavior = MyHarvestBehavior.new(record, activity_uri)
  #   behavior.process_record
  #
  # @example
  #   MyHarvestBehavior.process_record(record, activity_uri)
  #
  # @see Krirki::Harvester#run
  class HarvestBehavior
    # @!attribute activity_uri [r]
    #   a URI identifying the activity responsible for invoking the behavior
    # @!attribute record [r]
    #   the record to process with this behavior
    attr_reader :activity_uri, :record

    def initialize(record, activity_uri)
      @record = record
      @activity_uri = activity_uri
    end

    ##
    # Creates a new instance of this behavior with the given arguments
    # and calls `#process_record`.
    #
    # @param activity_uri
    # @param record
    # @see self#record, self#activity_uri for parameter usage
    def self.process_record(record, activity_uri)
      new(record, activity_uri).process_record
    end
  end
end
