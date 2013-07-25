class AddSitemapColumnsToCmsNodes < ActiveRecord::Migration
  def change
    add_column :cms_nodes, :sitemap_state, :string
    add_column :cms_nodes, :sitemap_sort_no, :integer
  end
end
