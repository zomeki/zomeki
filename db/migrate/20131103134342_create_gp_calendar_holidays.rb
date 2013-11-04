class CreateGpCalendarHolidays < ActiveRecord::Migration
  def change
    create_table :gp_calendar_holidays do |t|
      t.integer    :unid
      t.references :content

      t.string     :state
      t.string     :name
      t.date       :date
      t.text       :description
      t.string     :kind

      t.timestamps
    end
  end

end
