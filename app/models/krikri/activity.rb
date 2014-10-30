module Krikri
  ##
  # Activity wraps code execution with metadata about when it ran, which
  # agents were responsible.
  #
  # The following example will run the block given, and return an
  # Activity instance with the start and end times for the execution,
  # and knowledge that `my_software_agent` was the responsible agent.
  #
  #     activity = Activity.new(my_software_agent) do
  #       # code to run
  #     end
  #
  # TODO: Support persistence
  # TODO: should Activities be aware of which records (OriginalRecord,
  #       DPLA::MAP::Aggregations) they operate on?
  class Activity
    attr_reader :start_time, :end_time, :agent

    def initialize(agent)
      @agent = agent
      if block_given?
        set_start_time
        yield
        set_end_time
      end
    end

    def set_start_time
      @start_time = DateTime.now.utc
    end

    def set_end_time
      now = DateTime.now
      fail 'Start time must exist and be before now to set an end time' unless
        start_time && (start_time <= now)
      @end_time = now.utc
    end
  end
end
