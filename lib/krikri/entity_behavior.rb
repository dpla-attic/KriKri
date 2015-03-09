
# TODO: move to a subdirectory?

module Krikri
  class EntityBehavior
    attr_reader :activity
    def initialize(activity)
      @activity = activity
    end
    def generated_entities
      raise NotImplementedError 
    end
    def self.generated_entities(activity)
      new(activity).generated_entities
    end
  end
end
