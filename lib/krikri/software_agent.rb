module Krikri
  ##
  # SoftwareAgent is a mixin for logic common to code that generates a
  # Krikri::Activity.
  #
  module SoftwareAgent
    extend ActiveSupport::Concern

    Logger = ActiveSupport::TaggedLogging.new(Rails.logger)

    ##
    # Return an agent name suitable for saving in an Activity.
    # This is the name of the most-derived class upon which this is invoked.
    # @see Krikri::Activity
    def agent_name
      self.class.agent_name
    end

    ##
    # @abstract Perform this agent's work
    # @return [Boolean]
    def run
      fail NotImplementedError
    end

    ##
    # @see Krikri::SoftwareAgent#log
    def log(priority, msg)
      self.class.log(priority, msg)
    end

    ##
    # Store this agent's generator activity, which is the activity that
    # produced the target entities upon which the current agent will operate.
    #
    # It is assumed that the class that includes SoftwareAgent will define
    # class methods .entity_behavior and .generator_entity_behavior, which
    # return the class of the appropriate behavior.
    #
    # We look for either `generator_activity' or `generator_uri' in the `opts'
    # keys.  `generator_activity' must be a Krikri::Activity object, and
    # `generator_uri' can be a string or RDF::URI
    #
    # @see Krikri::Mapper::Agent
    # @see Krikri::Harvester
    #
    def set_generator_activity!(opts)
      if opts.include?(:generator_uri) && opts.include?(:generator_activity)
        fail 'generator_uri and generator_activity are redundant arguments'
      end
      if opts.include?(:generator_activity)
        @generator_activity = opts.delete(:generator_activity)
      elsif opts.include?(:generator_uri)
        generator_uri = opts.delete(:generator_uri)
        # allow generator_uri to be string or RDF::URI with `to_s' ...
        activity_id = generator_uri.to_s[/\d+$/].to_i  # 0 if no match
        fail "Can not determine ID for #{generator_uri}" if activity_id == 0
        @generator_activity = Krikri::Activity.find_by_id(activity_id)
        raise "Generator activity not found for id #{activity_id}" \
          if !@generator_activity
      end
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
