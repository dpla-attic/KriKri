
module Krikri
  ##
  # Base class for retrieval behaviors related to entities that were generated 
  # or revised by a `Krikri::Activity`.
  #
  # @example implementing an entity behavior
  #   class CustomBehavior < Krikri::EntityBehavior
  #     def entities(load = true, include_invalidated = false)
  #       activity_uris(include_invalidated) do |uri|
  #         # some behavior over URIs to return initialized entities
  #       end
  #     end
  #   end
  #
  # @example retrieving entities with a behavior
  #   Krikri::Activity.find(activity_id)
  #   CustomBehavor.entities(activity)
  #
  # A `SoftwareAgent` implements `#entity_behavior`, which returns an appropriate
  # subclass of `EntityBehavior`.  When an Activity is queried for its entities,
  # it instantiates an instance of its particular `SoftwareAgent`, and then
  # calls the `#entities` method of the agent's entity behavior.
  #
  # @see Krikri::Activity#entities
  # @see lib/krikri/entity_behaviors
  class EntityBehavior
    # @!attribute [r] activity
    #   @return [Krikri::Activity]
    attr_reader :activity

    ##
    # @param activity [Krikri::Activity]pp
    def initialize(activity)
      @activity = activity
    end

    ##
    # Return an Enumerator of objects that have been affected by our @activity.
    #
    # @param load [Boolean] `true` to force load the entities from the datastore
    #   on access
    # @param include_invalidated [Boolean] `true` to include entities marked as
    #   invalid.
    #
    # @return [Enumerator] the entities. When possible, they should be 
    #   initialized & retrieved lazily.
    #   
    #
    # @see lib/krikri/entity_behaviors
    # @see Krikri::Activity#entities
    #
    # @see Krikri::LDP::Invalidatable for more about "invalidated" entities
    def entities(*args)
      raise NotImplementedError
    end

    ##
    # Initializes an instance of this class with the given `Activity` and
    # returns an enumerator of the associated entities.
    #
    # @param activity   [Krikri::Activity]
    # @param load                [Boolean]
    # @param include_invalidated [Boolean]
    #
    # @see Krikri::EntityBehavior#entities
    # @see Krikri::Activity#entities
    def self.entities(activity, *args)
      new(activity).entities(*args)
    end

    private
    
    ##
    # Private utility method capturing common logic for applying entity logic to
    # uris gathered from the instance's `Krikri::Activity`.
    #
    # @param include_invalided [Boolean]
    #
    # @return [Enumerator::Lazy] the uris, lazily mapped to the behavior in the
    #   given block
    def activity_uris(include_invalidated, &block)
      activity.entity_uris(include_invalidated).lazy.map(&block)
    end
  end
end
