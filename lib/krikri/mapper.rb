require 'get_process_mem'
require 'memory_profiler'

module Krikri
  ##
  # Provides the public interface for defining and running metadata Mappings.
  # Define mappings by passing a block to #define with registered DSL methods;
  # in the simple case pass values to property names:
  #
  #   Krikri::Mapper.define do
  #     property_name   value
  #     property_two    another_value do |val|
  #       transform_value(val)
  #     end
  #
  #     nested_resource_property :class => DPLA::MAP::Agent do
  #       agent_property  agent_value
  #     end
  #   end
  #
  # #define accepts :class as an option, to specify the model class to use.
  # The default is DPLA::MAP::Aggregation:
  #
  #   Krikri::Mapper.define :class => MyModelClass {}
  #
  # Once a Mapping is defined, create mapped records with #map to return objects
  # of the specified class.
  #
  # @see Mapping
  # @see MappingDSL
  module Mapper
    module_function

    ##
    # Creates mappings and passes DSL methods through to them, then adds them to
    # a global registry.
    #
    # @param name [Symbol] a unique name for the mapper in the registry.
    # @param opts [Hash] options to pass to the mapping instance, options are:
    #   :class, :parser, and :parser_args
    # @yield A block passed through to the mapping instance containing the
    #   mapping in the language specified by MappingDSL
    def define(name, opts = {}, &block)
      klass = opts.fetch(:class, DPLA::MAP::Aggregation)
      parser = opts.fetch(:parser, Krikri::XmlParser)
      parser_args = opts.fetch(:parser_args, nil)
      map = Krikri::Mapping.new(klass, parser, *parser_args)
      map.instance_eval(&block) if block_given?
      Registry.register!(name, map)
    end

    ##
    # Maps OriginalRecords to the specified model class using a registered
    # Krikri::Mapping.
    #
    # @param name [Symbol] the name of a registered mapper to use
    # @param records A record or list of records that respond to #to_s
    # @return [Array] An array of objects of the model class, with properties
    #   set by the mapping.
    #
    # @see Mapping
    def map(name, records)
      records = Array(records) unless records.is_a? Enumerable

      #
      # MEMORY PROFILING
      #

      # i = 1
      # tried using `each` here instead of `map`, but it took longer and used
      # more memory...
      result = records.map do |rec|
        begin

          # CALL GC: this seems to help a little, but not a lot
          # Note that this was commented out when analyzing system calls in
          # https://digitalpubliclibraryofamerica.atlassian.net/wiki/display/TECH/Profiling+memory+growth+and+execution+time
          # so I don't think it's the cause of the repeated system calls
          # related to the smaps file.
          #
          # if i % 10 == 0
          #   GC.start
          # end
          # i += 1

          Registry.get(name).process_record(rec)

        rescue => e
          Rails.logger.error(e.message)
          nil
        end
      end
    end

    ##
    # An application-wide registry of defined mappings
    Registry = Class.new(Krikri::Registry)

    ##
    # A SoftwareAgent to run mapping processes.
    #
    # @example to map the records harvested by the harvest activity with ID 1:
    #   Krikri::Mapper::Agent.enqueue(name: :scdl_qdc,
    #     generator_uri: 'http://ldp.local.dp.la/ldp/activity/1')
    #
    # @see: Krikri::SoftwareAgent, Krikri::Activity
    class Agent
      include SoftwareAgent
      include EntityConsumer

      # @!attribute [r] name
      #   @return [Symbol]
      attr_reader :name

      ##
      # @return [Symbol] the default queue for jobs using this agent
      def self.queue_name
        :mapping
      end

      ##
      # @see Krikri::Activity#entities
      # @see Krikri::EntityBehavior
      # @see Krikri::SoftwareAgent#entity_behavior
      def entity_behavior
        @entity_behavior ||= Krikri::AggregationEntityBehavior
      end

      ##
      # @param opts [Hash]
      # @option opts [#to_sym] name  the symbol naming the mapping to use
      def initialize(opts = {})
        @name = opts.fetch(:name).to_sym
        @entity_behavior = self.class.entity_behavior
        assign_generator_activity!(opts)
      end

      ##
      # @param activity_uri [RDF::URI] the uri of the activity to attribute
      #   for provenance purposes (default: nil)
      # @see SoftwareAgent#run
      def run(activity_uri = nil)


        #
        # MEMORY PROFILING
        #

        inner_sum = 0
        outer_sum = 0

        outer_before = GetProcessMem.new.mb

        outer_start_time = Time.now.to_f

# UNCOMMENT MemoryProfiler for reports.  It uses a lot of memory. Try
# just 5 records.
#        MemoryProfiler.report(allow_files: ['query.rb', 'entity_behavior',
#                                            'provenance_query']) do

          Krikri::Mapper.map(name, entities).take(200).each do |rec|
            begin
              rec.mint_id! if rec.node?

              inner_before = GetProcessMem.new.mb

              activity_uri ? rec.save_with_provenance(activity_uri) : rec.save

              inner_after = GetProcessMem.new.mb
              inner_sum += inner_after - inner_before

            rescue => e
              Rails.logger.error("Error saving record: #{rec.try(:rdf_subject)}\n" \
                                 "#{e.message}\n#{e.backtrace}")
            end
          end

#        end.pretty_print(to_file: '/var/tmp/memoryprofile.txt')

        outer_end_time = Time.now.to_f
        outer_duration = outer_end_time - outer_start_time

        outer_after = GetProcessMem.new.mb
        outer_sum = outer_after - outer_before



        Krikri::Logger.log(:debug, "START MEM: #{outer_before} Mb")
        Krikri::Logger.log(:debug, "FINISH MEM: #{outer_after} Mb")
        Krikri::Logger.log(:debug, "Mapper.map took #{outer_duration} s")
        Krikri::Logger.log(
          :debug,
          "Activity#entity_uris took #{Krikri::StatCounter.get(:uris_each_solution_time)} s"
        )
        Krikri::Logger.log(:debug, "#run: #{inner_sum} Mb inside")
        Krikri::Logger.log(:debug, "#run: #{outer_sum} Mb outside")
        Krikri::Logger.log(
          :debug,
          "Mapping#process_record: #{Krikri::StatCounter.get(:process_record)} Mb"
        )
        Krikri::Logger.log(
          :debug,
          "OriginalRecordEntityBehavior#entities: " \
            "#{Krikri::StatCounter.get(:entities)} Mb"
        )
        Krikri::Logger.log(
          :debug,
          "Activity#entity_uris each_solution: " \
            "#{Krikri::StatCounter.get(:uris_each_solution)} Mb"
        )

      end
    end
  end

  class StatCounter
    include Singleton

    attr_reader :items
    delegate :[], :[]=, to: :items

    def initialize
      @items = {}
    end

    class << self
      def get(k)
        instance[k]
      end
      def set(k, v)
        instance[k] = v
      end
      def add(k, v)
        instance[k] = instance.items.key?(k) ? instance[k] + v : v
      end
    end
  end

end
