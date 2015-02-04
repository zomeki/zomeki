class CreateBizCalendarBussinessHolidays < ActiveRecord::Migration
  def up
    create_table :biz_calendar_bussiness_holidays do |t|
      t.integer    :unid
      t.belongs_to :place
      t.string     :state

      t.belongs_to :type
      t.date       :holiday_start_date
      t.date       :holiday_end_date
      t.string     :repeat_type
      t.date       :start_date
      t.date       :end_date

      t.timestamps
    end

  end

  def down
    drop_table :biz_calendar_bussiness_holidays
  end
end
