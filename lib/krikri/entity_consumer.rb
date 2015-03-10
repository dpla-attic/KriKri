module Krikri

  ##
  # A mixin for classes, like certain software agents, that generates entities.
  # For example, a mapper usually generates RDF aggregations, such that
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

    ##
    # Store this agent's generator activity, which is the activity that
    # produced the target entities upon which the current agent will operate.
    #
    # It is assumed that the class that includes SoftwareAgent will define
    # class methods .entity_behavior and .generator_entity_behavior, which
    # return the class of the appropriate behavior.
    #
    # We look for either `generator_activity' or `generator_uri' in the `opts'
    # keys.  `generator_activity' must be a Krikri::Activity object, and
    # `generator_uri' can be a string or RDF::URI
    #
    # @see Krikri::Mapper::Agent
    # @see Krikri::Harvester
    #
    def set_generator_activity!(opts)
      if opts.include?(:generator_uri)
        generator_uri = opts.delete(:generator_uri)
        # allow generator_uri to be string or RDF::URI with `to_s' ...
        activity_id = generator_uri.to_s[/\d+$/].to_i  # 0 if no match
        fail "Can not determine ID for #{generator_uri}" if activity_id == 0
        @generator_activity = Krikri::Activity.find_by_id(activity_id)
        raise "Generator activity not found for id #{activity_id}" \
          if !@generator_activity
      end
    end

    def generator_activity
      @generator_activity
    end

  end

end
