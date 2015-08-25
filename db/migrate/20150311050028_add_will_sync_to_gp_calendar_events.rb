class AddWillSyncToGpCalendarEvents < ActiveRecord::Migration
  def change
    add_column :gp_calendar_events, :will_sync, :string
  end
end
