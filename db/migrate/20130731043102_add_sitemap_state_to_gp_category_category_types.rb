class AddSitemapStateToGpCategoryCategoryTypes < ActiveRecord::Migration
  def change
    add_column :gp_category_category_types, :sitemap_state, :string
  end
end
