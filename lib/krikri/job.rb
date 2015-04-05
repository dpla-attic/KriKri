module Krikri
  ##
  # Generic Job class that gets extended by specific types of Jobs;
  # Harvest, Enrichment, etc.
  #
  # A Job is instantiated by the queue system and #perform is invoked to run the
  # job.  The Job looks up an Activity that was created when the job was
  # enqueued and calls Activity#run, passing Job#run as a block to perform the
  # actual work. This is necessary because the Activity is designed not to care
  # about what kind of job it's running.
  #
  # @see Krikri::Activity
  # @see https://github.com/resque/resque/tree/1-x-stable
  class Job
    @queue = nil
    ##
    # Perform the job.
    def self.perform(activity_id)
      activity = Krikri::Activity.find(activity_id)
      activity.run { |agent, activity_uri| run(agent, activity_uri) }
    end

    ##
    # Run the job's task. Receieves a `Krikri::SoftwareAgent` or other object
    # responding to `#run`.
    #
    # @param agent [#run] the agent to run the task
    # @param activity_uri  the URI of the activity responsible for
    #   generating the resources. Set this to (e.g.) prov:wasGeneratedBy
    def self.run(agent, activity_uri = nil)
      return agent.run unless activity_uri && agent.method(:run).arity != 0
      agent.run(activity_uri)
    end
  end
end
