class AddRepeatCriterionToBizCalendarBussinessHours < ActiveRecord::Migration
  def change
    add_column :biz_calendar_bussiness_hours, :repeat_criterion, :text
  end
end
