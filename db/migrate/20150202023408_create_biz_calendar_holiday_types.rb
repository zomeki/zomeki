class CreateBizCalendarHolidayTypes < ActiveRecord::Migration
  def up
    create_table :biz_calendar_holiday_types do |t|
      t.integer    :unid
      t.belongs_to :content
      t.string     :state

      t.string     :name
      t.string     :title
      t.timestamps
    end

    add_index :biz_calendar_holiday_types, :content_id
  end

  def down
    drop_table :biz_calendar_holiday_types
  end
end
