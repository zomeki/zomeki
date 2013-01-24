class CreatePortalCalendarEvents < ActiveRecord::Migration
  def up
		create_table :portal_calendar_events do |t|
      t.integer  :unid
      t.integer  :content_id
      t.string   :state,        :limit => 15
      t.datetime :published_at
      t.date     :event_date
      t.string   :event_uri
      t.string   :title
      t.text     :body,         :limit => 2147483647

			t.timestamps
    end

    add_index :portal_calendar_events, [:content_id, :published_at, :event_date], :name => :content_id

  end

  def down
		drop_table :portal_calendar_events
	end
end
