class AddLayoutIdToGnavMenuItems < ActiveRecord::Migration
  def change
    add_column :gnav_menu_items, :layout_id, :integer
    add_index :gnav_menu_items, :layout_id
  end
end
