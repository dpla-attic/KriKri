module Krikri
  ##
  # SoftwareAgent is a mixin for logic common to code that generates a
  # Krikri::Activity.
  #
  module SoftwareAgent
    extend ActiveSupport::Concern

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
    # Class methods for extension by ActiveSupport::Concern
    module ClassMethods

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
      #       endpoint: 'http://vcoai.lib.harvard.edu/vcoai/vc',
      #       set: 'dag'
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
      # @return [Boolean]
      def enqueue(job_class, opts = {})
        fail 'the given class has no #perform method' \
          unless job_class.respond_to?(:perform)
        fail 'opts is not a hash' unless opts.is_a?(Hash)
        activity = Krikri::Activity.create do |a|
          a.agent = agent_name
          a.opts = JSON.generate(opts)
        end
        Resque.enqueue(job_class, activity.id)
      end

    end

  end
end
