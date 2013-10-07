class AddFaxToSysGroups < ActiveRecord::Migration
  def change
    add_column :sys_groups, :fax, :string, :after => :tel
  end
end
