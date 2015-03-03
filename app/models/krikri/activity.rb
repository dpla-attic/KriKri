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
    # @!attribute agent
    #    @return [String] a string representing the Krikri::SoftwareAgent
    #                     responsible for the activity.
    # @!attribute end_time
    #    @return [DateTime] a datestamp marking the activity's competion
    # @!attribute opts
    #    @return [JSON] the options to pass to the #agent class when running
    #                   the activity
    # @!attribute start_time
    #    @return [DateTime] a datestamp marking the activity's start

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

    ##
    # Runs the block, setting the start and end time of the run. The given block
    # is passed an instance of the agent, and a URI representing this Activity.
    def run
      if block_given?
        update_attribute(:end_time, nil) if ended?
        set_start_time
        begin
          yield agent_instance, rdf_subject
        rescue => e
          Rails.logger.error("Error performing Activity: #{id}\n" \
                             "#{e.message}\n#{e.backtrace}")
          raise e
        ensure
          set_end_time
        end
      end
    end

    ##
    # Indicates whether the activity has ended. Does not distinguish between
    # successful and failed completion states.
    #
    # @return [Boolean] `true` if the activity has been marked as ended,
    #   else `false`
    def ended?
      !self.end_time.nil?
    end

    ##
    # Instantiates and returns an instance of the Agent class with the values in
    # opts.
    #
    # @return [Agent] an instance of the class stored in Agent
    def agent_instance
      @agent_instance ||= agent.constantize.new(parsed_opts)
    end

    def parsed_opts
      JSON.parse(opts, symbolize_names: true)
    end

    def rdf_subject
      RDF::URI(Krikri::Settings['marmotta']['ldp']) /
        Krikri::Settings['prov']['activity'] / id.to_s
    end

    ##
    # Return an Enumerator of URI strings of entities (e.g. aggregations or
    # original records) that pertain to this activity
    #
    # @return [Enumerator] URI strings
    def generated_entity_uris
      activity_uri = RDF::URI(rdf_subject)  # This activity's LDP URI
      query = Krikri::ProvenanceQueryClient.find_by_activity(activity_uri)
      query.each_solution.lazy.map do |s|
        s.record.to_s
      end
    end

  end
end
