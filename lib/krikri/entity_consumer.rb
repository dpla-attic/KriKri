module Krikri
  ##
  # A mixin for `Krikri::SoftwareAgent`s that use entities. Provides a 
  # mechanism for setting an `#entity_source` and consuming entities.
  #
  # For backwards compatability, this supports an older interface where entities
  # are selected based on a `generator_activity`.
  # 
  # @example the deprecated interface
  #   class AnAgent
  #     include Krikri::EntityConsumer
  #   end
  #   
  #   agent = AnAgent.new
  #   agent.assign_generator_activity!(generator_uri: 
  #     Krikri::Activity.find(1).rdf_subject)
  #
  #   agent.generator_activity.entities
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
        @entity_source = 
          @generator_activity = Krikri::Activity.from_uri(generator_uri)
      end
    end

    ##
    # @return [Enumerator<Krikri::LDP::Resource>] entities this agent will use
    def entities
      entity_source ? entity_source.entities : []
    end

    ##
    # @return [#entities, nil]
    def entity_source
      @entity_source
    end

    ##
    # Sets the entity source to a new instance of the provided class, 
    # initialized with the provided arguments and block.
    #
    # @param klass [Class] a class with an instance method `#entities`
    # @return [void]
    def set_entity_source!(klass, *args, &block)
      @entity_source = klass.new(*args, &block)
    end
  end
end
