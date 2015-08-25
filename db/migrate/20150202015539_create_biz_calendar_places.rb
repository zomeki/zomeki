class CreateBizCalendarPlaces < ActiveRecord::Migration
  def up
    create_table :biz_calendar_places do |t|
      t.integer    :unid
      t.belongs_to :content
      t.string     :state

      t.string     :url
      t.string     :title
      t.string     :summary
      t.string     :description
      t.string     :business_hours_state
      t.string     :business_hours_title
      t.string     :business_holiday_state
      t.string     :business_holiday_title

      t.integer    :sort_no
      t.timestamps
    end

    add_index :biz_calendar_places, :content_id
  end

  def down
    drop_table :biz_calendar_places
  end
end
