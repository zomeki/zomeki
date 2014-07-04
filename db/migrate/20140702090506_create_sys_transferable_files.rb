class CreateSysTransferableFiles < ActiveRecord::Migration
  def up
    create_table :sys_transferable_files do |t|
      t.belongs_to :site
      t.integer  :user_id
      t.integer  :version
      t.string   :operation
      t.string   :file_type
      t.string   :parent_dir
      t.string   :path
      t.string   :destination
      t.integer  :operator_id
      t.string   :operator_name
      t.datetime :operated_at
      t.integer  :item_id
      t.integer  :item_unid
      t.string   :item_model
      t.string   :item_name
      t.timestamps
    end
    add_index :sys_transferable_files, [:user_id, :operator_id]
  end

  def down
    drop_table :sys_transferable_files
  end
end
