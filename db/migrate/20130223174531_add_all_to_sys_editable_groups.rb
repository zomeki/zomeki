class AddAllToSysEditableGroups < ActiveRecord::Migration
  def change
    add_column :sys_editable_groups, :all, :boolean
  end
end
