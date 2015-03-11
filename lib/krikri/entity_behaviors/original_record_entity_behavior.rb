
module Krikri
  class OriginalRecordEntityBehavior < Krikri::EntityBehavior
    def generated_entities
      @activity.generated_entity_uris.lazy.map do |uri|
        OriginalRecord.load(uri)
      end
    end
  end
end
