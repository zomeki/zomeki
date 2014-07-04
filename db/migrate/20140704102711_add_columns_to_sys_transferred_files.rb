class AddColumnsToSysTransferredFiles < ActiveRecord::Migration
  def change
    add_column :sys_transferred_files, :user_id, :integer
    add_column :sys_transferred_files, :operator_id, :integer
    add_column :sys_transferred_files, :operator_name, :string
    add_column :sys_transferred_files, :operated_at, :datetime
    add_column :sys_transferred_files, :item_id, :integer
    add_column :sys_transferred_files, :item_unid, :integer
    add_column :sys_transferred_files, :item_model, :string
    add_column :sys_transferred_files, :item_name, :string

    add_index :sys_transferred_files, :user_id
    add_index :sys_transferred_files, :operator_id
  end
end
