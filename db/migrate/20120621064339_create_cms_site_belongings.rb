class CreateCmsSiteBelongings < ActiveRecord::Migration
  def change
    create_table :cms_site_belongings do |t|
      t.references :site
      t.references :user

      t.timestamps
    end
    add_index :cms_site_belongings, :site_id
    add_index :cms_site_belongings, :user_id
  end
end
