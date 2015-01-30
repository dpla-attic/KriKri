module Krikri
  # Institution models user-submitted information about an institution
  class Institution < ActiveRecord::Base
    has_many :harvest_sources, dependent: :destroy
    validates :name, presence: true
  end
end
