class CreatePortalCalendarEvents < ActiveRecord::Migration
  def up
		create_table :portal_calendar_events do |t|
      t.integer  :unid
      t.integer  :content_id
      t.string   :state,        :limit => 15
      t.date     :event_start_date
      t.date     :event_end_date
      t.string   :event_uri, :default => ''
      t.string   :title
      t.text     :body,         :limit => 2147483647
			t.integer  :event_genre_id,     :default => 0
			t.integer  :event_status_id,    :default => 0
			
			t.timestamps
    end
    add_index :portal_calendar_events, [:content_id, :event_start_date], :name => :content_id

		create_table :portal_calendar_genres do |t|
      t.integer  :unid
      t.integer  :content_id
      t.string   :state,     :default => 'public'
      t.string   :title,     :default => ''
			t.integer  :sort_no,   :default => 0
			
			t.timestamps
    end

		create_table :portal_calendar_statuses do |t|
      t.integer  :unid
      t.integer  :content_id
      t.string   :state,     :default => 'public'
      t.string   :title,     :default => ''
			t.integer  :sort_no,   :default => 0
			
			t.timestamps
    end
  end

  def down
		drop_table :portal_calendar_events
		drop_table :portal_calendar_genres
		drop_table :portal_calendar_statuses
	end
end
