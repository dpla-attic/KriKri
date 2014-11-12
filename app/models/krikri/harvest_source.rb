module Krikri
  # HarvestSource models user-submitted information about a harvest source
  # Some data may be used to create a Harvester
  class HarvestSource < ActiveRecord::Base
    belongs_to :institution
    validates :institution, :name, presence: true
  end
end
