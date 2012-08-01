class AddSiteImageIdToCmsSites < ActiveRecord::Migration
  def change
    add_column :cms_sites, :site_image_id, :integer
  end
end
