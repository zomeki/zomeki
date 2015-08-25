class AddRepeatIntervalAndRepeatWeekToBizCalendarBussinessHolidays < ActiveRecord::Migration
  def change
    add_column :biz_calendar_bussiness_holidays, :repeat_interval, :integer
    add_column :biz_calendar_bussiness_holidays, :repeat_week, :text
  end
end
