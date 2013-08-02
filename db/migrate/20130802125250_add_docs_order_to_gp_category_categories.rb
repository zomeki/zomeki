class AddDocsOrderToGpCategoryCategories < ActiveRecord::Migration
  def change
    add_column :gp_category_categories, :docs_order, :string
  end
end
