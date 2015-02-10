class AddRepeatIntervalAndRepeatWeekToBizCalendarBussinessHours < ActiveRecord::Migration
  def change
    add_column :biz_calendar_bussiness_hours, :repeat_interval, :integer
    add_column :biz_calendar_bussiness_hours, :repeat_week, :text
  end
end
