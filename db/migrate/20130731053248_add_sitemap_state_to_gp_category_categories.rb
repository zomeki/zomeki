class AddSitemapStateToGpCategoryCategories < ActiveRecord::Migration
  def change
    add_column :gp_category_categories, :sitemap_state, :string
  end
end
