class AddSyncExportedToGpCalendarEvents < ActiveRecord::Migration
  def change
    add_column :gp_calendar_events, :sync_exported, :string
  end
end
