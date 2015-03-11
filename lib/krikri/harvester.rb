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
  #    - #run. Wraps persistence of each record returned by #records.
  #      Runs a full harvest, processing the created `record_class`
  #      instances through `harvest_behavior`, given the options passed
  #      to #initialize.
  #
  # When including, add a call to Krikri::Harvester::Registry.register() to
  # put it in the registry so that it can be looked up.
  #
  # @see Krikri::Engine
  module Harvester
    extend ActiveSupport::Concern
    include SoftwareAgent

    attr_accessor :uri, :name

    included do
      class << self
        ##
        # @see SoftwareAgent#queue_name
        def queue_name
          :harvest
        end
      end
    end

    ##
    # @see Krikri::Activity#generated_entities
    # @see Krikri::EntityBehavior
    def entity_behavior
      Krikri::OriginalRecordEntityBehavior
    end

    ##
    # Accepts options for a generic harvester:
    #   uri: a URI for the harvest endpoint or provider
    #   name: a name for the harvester or provider, SHOULD be supplied when the
    #         provider does not use universally unique identifiers (optional).
    #   record_class: Class of records to generate (optional; defaults to
    #                 Krikri::OriginalRecord).
    #   id_minter: Module to create identifiers for generated records (optional;
    #              defaults to Krikri::Md5Minter)
    #   harvest_behavior: A behavior object implementing `#process_record`
    #
    # Pass harvester specific options to inheriting classes under a key for
    # that harvester. E.g. { uri: my_uri, oai: { metadata_prefix: :oai_dc } }
    #
    # @param opts [Hash] a hash of options
    def initialize(opts = {})
      @uri = opts.fetch(:uri)
      @name = opts.delete(:name)
      @record_class = opts.delete(:record_class) { Krikri::OriginalRecord }
                      .to_s.constantize
      @id_minter = opts.delete(:id_minter) { Krikri::Md5Minter }
                   .to_s.constantize
      @harvest_behavior = opts.delete(:harvest_behavior) do
        Krikri::Harvesters::BasicSaveBehavior
      end.to_s.constantize
    end

    delegate :process_record, :to => :@harvest_behavior

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
    # Run the harvest.
    #
    # Individual records are processed through `#process_record` which is
    # delegated to the harvester's `@harvest_behavior` by default.
    #
    # @return [Boolean]
    # @see Krirki::Harvesters:HarvestBehavior
    def run(activity_uri = nil)
      log :info, 'harvest is running'
      records.each do |rec|
        begin
          process_record(rec, activity_uri)
        rescue => e
          log :error, "Error harvesting record:\n#{rec.content}\n\t" \
                      "with message:\n#{e.message}"
          next
        end
      end
      log :info, 'harvest is done'
      true
    end

    ##
    # An application-wide registry of defined Harvesters.
    Registry = Class.new(Krikri::Registry)

    ##
    # @abstract Return initialization options for the harvester.
    #   The harvester will expect to receive these upon instantiation (in the
    #   opts argument to #initialize), in the form:
    #   {
    #      key: <symbol for this harvester>,
    #      opts: {
    #        option_name: {type: :type, required: <boolean>,
    #                      multiple_ok: <boolean, default false>}
    #      }
    #   }
    #   ... where type could be :uri, :string, :int, etc.
    #   ... and multiple_ok means whether it's allowed to be an array
    #   ... for example, for OAI this might be:
    #   {key: :oai,
    #    set: {type: :string, required: false, multiple_ok: true},
    #    metadata_prefix: {type: string, required: true}}
    #
    # @todo The actual type token values and how they'll be used is to be
    #   determined, but something should exist for providing validation
    #   guidelines to a client so it doesn't have to have inside knowledge of
    #   the harvester's code.
    #
    # @note The options are going to vary between harvesters.  Some options
    #   are going to be constant for the whole harvest, and some are going to
    #   be lists that get iterated over.  For example, a set or collection.
    #   There will be an ingestion event where we want multiple jobs enqueued,
    #   one per set or collection.  The one option (a list) that would vary
    #   from harvest job to harvest job might be 'set' (in the case of OAI).
    #   This method doesn't solve how that's going to happen, but simply
    #   provides, as a convenience, the options that the harvester wants to
    #   see.
    #
    def self.expected_opts
      raise NotImplementedError
    end

    private

    ##
    # Given a seed, sends a request for an id to the minter.
    #
    # @param seed [#to_s] seed to pass to minter
    def mint_id(seed)
      @id_minter.create(*[seed, @name].compact)
    end
  end
end
