module Krikri
  ##
  # Activity wraps code execution with metadata about when it ran, which
  # agents were responsible.  It is designed to run a variety of different
  # jobs, and its #run method is passed a block that performs the actual work.
  # It records the start and end time of the job run, and provides the name of
  # the agent to whomever needs it, but it does not care what kind of activity
  # it is -- harvest, enrichment, etc.
  #
  class Activity < ActiveRecord::Base

    validate :agent_must_be_a_software_agent

    def agent_must_be_a_software_agent
      errors.add(:agent, 'does not represent a SoftwareAgent') unless
        agent.constantize < Krikri::SoftwareAgent
    end

    def set_start_time
      update_attribute(:start_time, DateTime.now.utc)
    end

    def set_end_time
      now = DateTime.now.utc
      fail 'Start time must exist and be before now to set an end time' unless
        self[:start_time] && (self[:start_time] <= now)
      update_attribute(:end_time, now)
    end

    def run
      if block_given?
        set_start_time
        yield
        set_end_time
      end
    end

  end
end
