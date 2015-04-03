class AddQaReport < ActiveRecord::Migration
  def change
    create_table :krikri_qa_reports do |t|
      t.string :provider
      t.text :field_report, limit: nil
      t.text :count_report, limit: nil

      t.timestamps
    end
  end
end
