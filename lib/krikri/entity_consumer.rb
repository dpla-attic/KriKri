module Krikri
  ##
  # A mixin for classes, like certain `SoftwareAgent`s, that generates entities.
  # For example, a mapper usually generates `DPLA::MAP::Aggregation`s, such that
  # Mapper::Agent includes EntityConsumer, and a mapper agent is instantiated
  # with
  #   a = Krikri::Mapper::Agent.new({
  #     generator_uri: 'http://some.org/activity/1'
  #   })
  # such that
  #   a.generator_activity
  # returns a Krikri::Activity
  #
  module EntityConsumer
    extend ActiveSupport::Concern

    included { attr_reader :generator_activity }

    ##
    # Store this agent's generator activity, which is the activity that
    # produced the target entities upon which the current agent will operate.
    #
    # It is assumed that the agent class will define #entity_behavior, which
    # returns the class of the appropriate behavior.
    #
    # `generator_uri' can be a string or RDF::URI.
    #
    # In the future, we might want to take a `generator_activity' parameter,
    # because not every activity will modify its entities with provenance
    # messages; an indexing activity, in particular.  In this case an LDP URI
    # representing the activity is not relevant.
    #
    # @see Krikri::Mapper::Agent
    # @see Krikri::Harvester
    def assign_generator_activity!(opts)
      if opts.include?(:generator_uri)
        generator_uri = opts.delete(:generator_uri)
        # allow generator_uri to be string or RDF::URI with `to_s' ...
        activity_id = generator_uri.to_s[/\d+$/].to_i  # 0 if no match
        fail "Can not determine ID for #{generator_uri}" if activity_id == 0
        @generator_activity = Krikri::Activity.find_by_id(activity_id)
        raise "Generator activity not found for id #{activity_id}" \
          unless @generator_activity
      end
    end
  end
end
