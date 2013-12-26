class AddSitemapStateToGnavMenuItems < ActiveRecord::Migration
  def change
    add_column :gnav_menu_items, :sitemap_state, :string
  end
end
