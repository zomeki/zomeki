class ChangeSyncSourceIdOnGpCalendarEvents < ActiveRecord::Migration
  def up
    change_column :gp_calendar_events, :sync_source_id, :string
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
