class CreateBizCalendarBussinessHours < ActiveRecord::Migration
  def up
    create_table :biz_calendar_bussiness_hours do |t|
      t.integer    :unid
      t.belongs_to :place
      t.string     :state

      t.date       :fixed_start_date
      t.date       :fixed_end_date
      t.string     :repeat_type
      t.date       :start_date
      t.date       :end_date
      t.time       :business_hours_start_time
      t.time       :business_hours_end_time
      
      t.timestamps
    end
  end

  def down
    drop_table :biz_calendar_bussiness_hours
  end
end
