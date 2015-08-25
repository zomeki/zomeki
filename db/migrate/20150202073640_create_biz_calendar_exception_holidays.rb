class CreateBizCalendarExceptionHolidays < ActiveRecord::Migration
  def up
    create_table :biz_calendar_exception_holidays do |t|
      t.integer    :unid
      t.belongs_to :place
      t.string     :state

      t.date       :start_date
      t.date       :end_date

      t.timestamps
    end
  end

  def down
    drop_table :biz_calendar_exception_holidays
  end
end
