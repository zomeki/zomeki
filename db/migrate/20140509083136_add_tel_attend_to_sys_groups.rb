class AddTelAttendToSysGroups < ActiveRecord::Migration
  def change
    add_column :sys_groups, :tel_attend, :string
  end
end
