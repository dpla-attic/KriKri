
module Krikri
  ##
  # Base class for behaviors related to entities that are generated or revised
  # by activities.
  #
  # A SoftwareAgent implements #entity_behavior, which returns an appropriate
  # subclass of EntityBehavior.  When an Activity is queried for its entities,
  # it instantiates an instance of its particular SoftwareAgent, and then
  # calls the #entities method of the agent's entity behavior.
  #
  # @see Krikri::Activity#entities
  # @see lib/krikri/entity_behaviors
  #
  class EntityBehavior
    attr_reader :activity
    def initialize(activity)
      @activity = activity
    end

    ##
    # Return an Enumerator of objects that have been affected by our @activity.
    #
    # @return [Enumerator] objects
    # @see lib/krikri/entity_behaviors
    # @see Krikri::Activity#entities
    #
    def entities(*args)
      raise NotImplementedError 
    end

    ##
    # @see Krikri::Activity#entities
    # @see Krikri::EntityBehavior#entities
    #
    def self.entities(activity, *args)
      new(activity).entities(*args)
    end
  end
end
