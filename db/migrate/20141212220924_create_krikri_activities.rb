class CreateKrikriActivities < ActiveRecord::Migration
  def change
    create_table :krikri_activities do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.string :agent
      t.string :opts
      t.timestamps
    end
  end
end
