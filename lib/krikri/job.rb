module Krikri
  ##
  # Generic Job class the gets extended by specific types of Jobs;
  # Harvest, Enrichment, etc.
  class Job
    @queue = nil
    ##
    # Perform the job.
    def self.perform(activity_id)
      activity = Krikri::Activity.find(activity_id)
      opts = JSON.parse(activity['opts'], symbolize_names: true)
      agent = activity['agent'].constantize.new(opts)
      activity.run { run(agent) }
    end

    private

    ##
    # @abstract run the job's task. Implement the actual task
    #   against the agent passed in.
    # @param agent  the agent to run the task
    def self.run(_)
      raise NotImplementedError
    end
  end
end
