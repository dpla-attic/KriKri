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
      self.class.to_s
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
      # @see SoftwareAgent#agent_name
      def agent_name
        to_s
      end

      ##
      # Enqueue a job.
      #
      # Example:
      #
      #   Krikri::Harvesters::OAIHarvester.enqueue(
      #     Krikri::HarvestJob,
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
      # @see https://github.com/resque/resque/tree/1-x-stable
      # @see Krikri::HarvestJob
      # @see Krikri::SoftwareAgent#agent_name
      # @see Krikri::Harvester::expected_opts
      # @return [Boolean]
      def enqueue(job_class, opts = {})
        fail "#{job_class} has no #perform method" unless
          job_class.respond_to?(:perform)
        fail 'opts is not a hash' unless opts.is_a?(Hash)
        activity = Krikri::Activity.create do |a|
          a.agent = agent_name
          a.opts = JSON.generate(opts)
        end
        log :info, "created activity #{activity.id}"
        Resque.enqueue(job_class, activity.id)
        log :info, "enqueued #{job_class}"
        true
      end

    end

  end
end
