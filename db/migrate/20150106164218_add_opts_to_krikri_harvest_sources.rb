class AddOptsToKrikriHarvestSources < ActiveRecord::Migration
  def change
    add_column :krikri_harvest_sources, :opts, :text
  end
end
