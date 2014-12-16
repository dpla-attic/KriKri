module Krikri
  ##
  # Generic Job class the gets extended by specific types of Jobs;
  # Harvest, Enrichment, etc.
  class Job
    @queue = nil
    ##
    # @abstract Perform the job; called by the queue system
    def self.perform(*)
      fail NotImplementedError
    end
  end
end
