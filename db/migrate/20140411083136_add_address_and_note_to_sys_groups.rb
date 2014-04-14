class AddAddressAndNoteToSysGroups < ActiveRecord::Migration
  def change
    add_column :sys_groups, :address, :string
    add_column :sys_groups, :note, :string
  end
end
