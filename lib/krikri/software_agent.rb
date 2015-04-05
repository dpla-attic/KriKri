module Krikri
  ##
  # SoftwareAgent is a mixin for logic common to code that generates a
  # Krikri::Activity.
  #
  module SoftwareAgent
    extend ActiveSupport::Concern

    included do
      attr_writer :entity_behavior
    end

    Logger = ActiveSupport::TaggedLogging.new(Rails.logger)

    ##
    # Return the EntityBehavior associated with the SoftwareAgent.
    # Meant to be overridden as necessary.
    #
    # @see Krikri::Activity#entities
    # @see Krikri::EntityBehavior
    #
    def entity_behavior
      @entity_behavior ||= nil
    end

    ##
    # Return an agent name suitable for saving in an Activity.
    # This is the name of the most-derived class upon which this is invoked.
    #
    # @return [String]
    # @see Krikri::Activity
    def agent_name
      self.class.agent_name
    end

    ##
    # @abstract Perform this agent's work. The method may accept an
    #   `activity_uri` to record as the Activity in provenance metadata.
    #   If so, the implementation must be optional and handle `nil` values by
    #   declining to record provenance
    #
    # @return [Boolean] `true` if the run has succeeded; otherwise `false`
    #
    # @see Krirkri::Activity
    # @see Krikri::Job.run
    def run
      fail NotImplementedError
    end

    ##
    # @see Krikri::SoftwareAgent#log
    def log(priority, msg)
      self.class.log(priority, msg)
    end

    ##
    # Class methods for extension by ActiveSupport::Concern
    module ClassMethods

      ##
      # Log a message, tagged in a way suitable for software agents.
      # @see Krikri::SoftwareAgent::method_missing
      def log(priority, msg)
        Krikri::SoftwareAgent::Logger.tagged(
          Time.now.to_s, Process.pid, to_s
        ) do
          Krikri::SoftwareAgent::Logger.send(priority, msg)
        end
      end

      ##
      # @return a string representation of this SoftwareAgent class
      def agent_name
        to_s
      end

      ##
      # @return the name of the default queue for jobs invoking this
      #   SoftwareAgent
      def queue_name
        agent_name.downcase
      end

      ##
      # Enqueue a job.
      #
      # @example
      #   MyAgent.enqueue(:name => my_job)
      #
      # @example
      #   Krikri::Harvesters::OAIHarvester.enqueue(
      #     :harvest,
      #     opts = {
      #       uri: 'http://vcoai.lib.harvard.edu/vcoai/vc',
      #       oai: { set: 'dag', metadata_prefix: 'mods' }
      #     }
      #   )
      #
      # A worker process must be started to process jobs in the "harvest"
      # queue, either before or after they are enqueued:
      #
      #  shell$ QUEUE=harvest bundle exec rake environment resque:work
      #
      # This depends on Redis and Marmotta being available and properly
      # configured (if necessary) in the Rails app.
      #
      # @param queue_name [#to_s] the Resque queue name
      # @param opts [Hash] a hash of options that will be used to initialize
      #   the agent (an instance of this class).
      #
      # @return [Boolean]
      #
      # @see https://github.com/resque/resque/tree/1-x-stable
      # @see Krikri::Job
      # @see Krikri::SoftwareAgent#agent_name
      # @see Krikri::Harvester::expected_opts
      def enqueue(*args)
        queue = args.shift unless args.first.is_a? Hash
        queue ||= queue_name
        opts = args.shift || {}
        fail ArgumentError, "unexpected arguments #{args}" unless args.empty?
        fail ArgumentError, 'opts is not a hash' unless opts.is_a?(Hash)

        activity = Krikri::Activity.create do |a|
          a.agent = agent_name
          a.opts = JSON.generate(opts)
        end

        log :info, "created activity #{activity.id}"
        Resque.enqueue_to(queue, Krikri::Job, activity.id)
        log :info, "enqueued to #{queue}"
        true
      end

    end

  end
end
