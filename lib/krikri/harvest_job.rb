module Krikri
  ##
  # HarvestJob: perform enqueued Krikri::Harvesters jobs
  #
  # @see Krikri::Job, Krikri::Activity
  # @see https://github.com/resque/resque/tree/1-x-stable
  class HarvestJob < Krikri::Job
    @queue = :harvest

    def self.run(harvester, activity_uri = nil)
      harvester.run(activity_uri)
    end
  end
end
