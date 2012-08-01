class AddBodyToCmsSites < ActiveRecord::Migration
  def change
    add_column :cms_sites, :body, :text
  end
end
