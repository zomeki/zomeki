class AddColumnRepeatToGpCalendarHolidays < ActiveRecord::Migration
  def change
    add_column :gp_calendar_holidays, :repeat, :boolean
  end
end
