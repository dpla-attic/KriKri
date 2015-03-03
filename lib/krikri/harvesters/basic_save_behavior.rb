module Krikri::Harvesters
  ##
  # Harvest behavior that call a simple save on a record
  class BasicSaveBehavior < HarvestBehavior
    def process_record
      record.save(activity_uri)
    end
  end
end
