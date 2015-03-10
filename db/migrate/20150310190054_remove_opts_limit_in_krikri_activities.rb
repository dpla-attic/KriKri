class RemoveOptsLimitInKrikriActivities < ActiveRecord::Migration
  def change
    change_column :krikri_activities, :opts, :text, :limit => nil
  end
end
