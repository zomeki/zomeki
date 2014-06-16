class CreateSysTransferredFiles < ActiveRecord::Migration
  def up
    create_table :sys_transferred_files do |t|
      t.belongs_to :site
      #t.datetime :transferred_at
      t.integer  :version
      t.string   :operation
      t.string   :file_type
      t.string   :parent_dir
      t.string   :path
      t.string   :destination
      #t.integer  :size
      #t.datetime :last_modified_at
      #t.string   :mime_type

      t.timestamps
    end
    add_index :sys_transferred_files, :version
    add_index :sys_transferred_files, :created_at
    #add_index :sys_transferred_files, :last_modified_at
  end

  def down
    drop_table :sys_transferred_files
  end
end
