module Krikri
  # HarvestSource models user-submitted information about a harvest source
  # Some data may be used to create a Harvester
  class HarvestSource < ActiveRecord::Base
    belongs_to :institution
    validates_presence_of :institution, :name, :source_type, :uri
    validates :uri,
              format: { with: URI.regexp },
              if: proc { |a| a.uri.present? }
  end
end
