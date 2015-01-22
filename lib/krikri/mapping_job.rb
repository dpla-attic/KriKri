module Krikri
  ##
  # MappingJob: perform enqueued Krikri::Mapper::Agent
  #
  # @see: Krikri::Mapper, Krikri::Mapper::Agent
  class MappingJob < Krikri::Job
    @queue = :mapping

    def self.run(mapper, activity_uri = nil)
      mapper.run(activity_uri)
    end
  end
end
