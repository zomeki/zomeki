class AddOgColumnsToCmsSites < ActiveRecord::Migration
  def change
    add_column :cms_sites, :og_type, :string
    add_column :cms_sites, :og_title, :string
    add_column :cms_sites, :og_description, :text
    add_column :cms_sites, :og_image, :string
  end
end
