module Krikri
  ##
  # Harvester is the abstract interface for aggregating records from a
  # source. Harvesters need to be able to:
  #
  #   - Enumerate record ids (#record_ids)
  #   - Enumerate records (#records)
  #   - Retrieve individual records (#get_record)
  #
  # Implementations of Enumerators in subclasses should be lazy,
  # avoiding loading large numbers of records into memory or sending
  # unnecessary requests to providers. The following example should be
  # safe:
  #
  #    my_harvester.record_ids.take(100)
  #
  # This parent class implements a few generic methods based on the
  # services outlined above:
  #
  #    - #count. This assumes that lazy counting is implemented on the
  #      Enumerable returned by #record_ids. If not, it is strongly
  #      recommended to override this method in your subclass with
  #      an efficient implementation.
  #    - #run. Wraps persistence of each record returned by #records
  #      in an Activity to run a full harvest.
  class Harvester
    extend SoftwareAgent

    ##
    # @abstract Provide a low-memory, lazy enumerable for record ids.
    #
    # The following usage should be safe:
    #
    #     record_ids.each do |id|
    #        some_operation(id)
    #     end
    #
    # @return [Enumerable<String>] The identifiers included in the harvest.
    def record_ids
      raise NotImplementedError
    end

    ##
    # @return [Integer] A count of the records expected in the harvest.
    # @note override if #record_ids does not implement a lazy
    #   Enumerable#count.
    def count
      record_ids.count
    end

    ##
    # @abstract Provide a low-memory, lazy enumerable for records.
    # @return [Enumerable<Krikri::OriginalRecord>] The harvested records.
    def records
      raise NotImplementedError
    end

    ##
    # @abstract Get a single record by identifier.
    # @param identifier [#to_s] the identifier for the record to be
    #   retrieved
    # @return [Krikri::OriginalRecord]
    def get_record(_)
      raise NotImplementedError
    end

    ##
    # Creates a harvest activity and runs harvest.
    # This should be idempotent so it can be safely retried on errors.
    #
    # @return [Boolean]
    def run
      Krikri::Activity.new(self) do
        records.each(&:save)
      end
    end
  end
end
