class ChangeOptsInKrikriActivities < ActiveRecord::Migration
  def change
    change_column :krikri_activities, :opts, :text
  end
end
