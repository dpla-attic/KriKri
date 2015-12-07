class CreateKrikriEnrichmentProfiles < ActiveRecord::Migration
  def change
    create_table :krikri_enrichment_profiles do |t|

      t.timestamps
    end
  end
end
