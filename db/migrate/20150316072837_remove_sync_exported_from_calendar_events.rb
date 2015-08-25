class RemoveSyncExportedFromCalendarEvents < ActiveRecord::Migration
  def up
    remove_column :gp_calendar_events, :sync_exported
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
