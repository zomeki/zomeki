class ReplaceUserWithGroupOnCmsSiteBelongings < ActiveRecord::Migration
  def up
    add_column :cms_site_belongings, :group_id, :integer
    add_index :cms_site_belongings, :group_id
    remove_column :cms_site_belongings, :user_id
  end

  def down
    add_column :cms_site_belongings, :user_id, :integer
    add_index :cms_site_belongings, :user_id
    remove_column :cms_site_belongings, :group_id
  end
end
