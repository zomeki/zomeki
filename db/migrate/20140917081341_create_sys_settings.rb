class CreateSysSettings < ActiveRecord::Migration
  def up
    create_table :sys_settings do |t|
      t.string   :name
      t.text     :value
      t.integer  :sort_no
      t.text     :extra_value
      t.timestamps
    end
  end

  def down
    drop_table :sys_settings
  end
end
