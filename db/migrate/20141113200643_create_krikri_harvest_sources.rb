class CreateKrikriHarvestSources < ActiveRecord::Migration
  def change
    create_table :krikri_harvest_sources do |t|
      t.integer :institution_id
      t.string :name
      t.string :source_type
      t.string :metadata_schema
      t.string :uri
      t.text :notes

      t.timestamps
    end
  end
end
