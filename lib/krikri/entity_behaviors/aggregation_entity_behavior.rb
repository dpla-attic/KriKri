
module Krikri
  class AggregationEntityBehavior < Krikri::EntityBehavior
    def generated_entities
      @activity.generated_entity_uris.lazy.map do |uri|
        agg = DPLA::MAP::Aggregation.new(uri)
        agg.get   # slow?
        agg
      end
    end
  end
end
