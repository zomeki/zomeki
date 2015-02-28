class AddSyncSourceSourceClassToGpCalendarEvents < ActiveRecord::Migration
  def change
    add_column :gp_calendar_events, :sync_source_source_class, :string
  end
end
