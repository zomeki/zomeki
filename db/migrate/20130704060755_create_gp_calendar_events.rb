class CreateGpCalendarEvents < ActiveRecord::Migration
  def change
    create_table :gp_calendar_events do |t|
      t.integer    :unid
      t.references :content

      t.string     :state
      t.date       :started_on
      t.date       :ended_on
      t.string     :name
      t.string     :title
      t.string     :href
      t.string     :target
      t.text       :description

      t.timestamps
    end
  end
end
