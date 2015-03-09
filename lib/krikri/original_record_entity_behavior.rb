
# TODO: move to a subdirectory?

module Krikri
  class OriginalRecordEntityBehavior < EntityBehavior
    def generated_entities
      @activity.generated_entity_uris.lazy.map do |uri|
        OriginalRecord.load(uri)
      end
    end
  end
end
