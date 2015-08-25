class AddEndTypeAndEndTimesToBizCalendarBussinessHours < ActiveRecord::Migration
  def change
    add_column :biz_calendar_bussiness_hours, :end_type, :integer
    add_column :biz_calendar_bussiness_hours, :end_times, :integer
  end
end
