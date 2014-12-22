module Krikri
  ##
  # HarvestJob: perform enqueued Krikri::Harvesters jobs
  #
  # A HarvestJob is instantiated by the queue system and #perform is invoked
  # to run the job.  The HarvestJob looks up an Activity that was created when
  # the job was enqueued, and instantiates the particular Harvester that it
  # specifies as its agent, and has the Activity run it.  This is necessary
  # because the Activity is designed not to care about what kind of job it's
  # running.
  #
  # @see Krikri::Activity
  # @see https://github.com/resque/resque/tree/1-x-stable
  #
  class HarvestJob < Krikri::Job
    @queue = :harvest
    def self.perform(activity_id)
      activity = Krikri::Activity.find(activity_id)
      classname = activity['agent']
      opts = JSON.parse(activity['opts'], symbolize_names: true)
      harvester = classname.constantize.new(opts)
      activity.run { harvester.run }
    end
  end
end
