class CreateSysClosers < ActiveRecord::Migration
  def up
    create_table :sys_closers do |t|
      t.integer  :unid
      t.string   :dependent, :limit => 64
      t.string   :path
      t.string   :content_hash
      t.datetime :published_at
      t.datetime :republished_at
      t.timestamps
    end
    add_index :sys_closers, [:unid, :dependent]
  end

  def down
    drop_table :sys_closers
  end
end
