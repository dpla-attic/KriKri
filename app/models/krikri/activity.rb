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
    #      responsible for the activity.
    # @!attribute start_time
    #    @return [DateTime] a datestamp marking the activity's start
    # @!attribute end_time
    #    @return [DateTime] a datestamp marking the activity's competion
    # @!attribute opts
    #    @return [JSON] the options to pass to the #agent class when running
    #      the activity
    
    validate :agent_must_be_a_software_agent

    ##
    # @example building a valid URI from the base
    #   Krikri::Activity.base_uri / 1
    #   
    # @return [RDF::URI] the configured base URI for this class
    def self.base_uri
      RDF::URI(Krikri::Settings['marmotta']['ldp']) /
        Krikri::Settings['prov']['activity']
    end

    ##
    # @param uri [#to_s] a uri for this activity
    #
    # @return [Krikri::Activity] the activity with the given uri
    #
    # @raise [RuntimeError] if the URI form does not match the activity
    # @raise [ActiveRecord::RecordNotFound] if no activity is found
    def self.from_uri(uri)
      raise "Cannot find #{self} from URI: #{uri}" unless 
        uri.start_with? base_uri

      find(uri.to_s.sub(base_uri.to_s, '').sub('/', ''))
    end

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
    # 
    # Handles logging of activity start/stop and failure states.
    #
    # @raise [RuntimeError] re-raises logged errors on Activity failure
    def run
      if block_given?
        update_attribute(:end_time, nil) if ended?
        Krikri::Logger
          .log(:info, "Activity #{agent.constantize}-#{id} is running")
        set_start_time
        begin
          yield agent_instance, rdf_subject
        rescue => e
          Krikri::Logger.log(:error, "Error performing Activity: #{id}\n" \
                                     "#{e.message}\n#{e.backtrace}")
          raise e
        ensure
          set_end_time
          Krikri::Logger
            .log(:info, "Activity #{agent.constantize}-#{id} is done")
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
    
    ##
    # @return [Hash] the options parsed as JSON
    def parsed_opts
      JSON.parse(opts, symbolize_names: true)
    end

    ##
    # @return [RDF::URI] the uri for this activity
    def rdf_subject
      self.class.base_uri / id.to_s
    end
    alias_method :to_term, :rdf_subject

    ##
    # @return [String] a string reprerestation of the activity
    def to_s
      inspect.to_s
    end

    ##
    # Return an Enumerator of URI strings of entities (e.g. aggregations or
    # original records) that pertain to this activity
    #
    # @param  include_invalidated [Boolean] Whether to include entities that
    #   have been invalidated with prov:invalidatedAtTime. Default: false
    #
    # @return [Enumerator] URI strings
    #
    # @see Krikri::ProvenanceQueryClient#find_by_activity regarding
    #   invalidation.
    #
    def entity_uris(include_invalidated = false)
      activity_uri = RDF::URI(rdf_subject)  # This activity's LDP URI
      query = Krikri::ProvenanceQueryClient
        .find_by_activity(activity_uri, include_invalidated)
      query.each_solution.lazy.map do |s|
        s.record.to_s
      end
    end

    ##
    # Return an Enumerator of entities (e.g. aggregations or original records)
    # that have been affected by this activity.
    #
    # The kind of object that is returned depends on the EntityBehavior class
    # that is associated with the SoftwareAgent that is represented by the
    # Activity's `agent' field.
    #
    # @param [Array<Object>] *args Arguments to pass along to
    #                              EntityBehavior#entities
    # @return [Enumerator] Objects
    def entities(*args)
      agent_instance.entity_behavior.entities(self, *args)
    end
  end
end
