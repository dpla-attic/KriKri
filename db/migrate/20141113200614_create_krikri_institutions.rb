class CreateKrikriInstitutions < ActiveRecord::Migration
  def change
    create_table :krikri_institutions do |t|
      t.string :name
      t.text :notes

      t.timestamps
    end
  end
end
