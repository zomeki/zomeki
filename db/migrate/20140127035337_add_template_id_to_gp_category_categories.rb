class AddTemplateIdToGpCategoryCategories < ActiveRecord::Migration
  def change
    add_column :gp_category_categories, :template_id, :integer
  end
end
