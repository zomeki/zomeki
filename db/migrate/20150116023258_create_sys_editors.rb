class CreateSysEditors < ActiveRecord::Migration
  def up
    create_table :sys_editors do |t|
      t.integer  :parent_unid
      t.timestamps
      t.integer  :user_id
      t.integer  :group_id
    end
  end

  def down
    drop_table :sys_editors
  end
end
