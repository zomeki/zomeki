class AddGroupCodeToGpCategoryCategories < ActiveRecord::Migration
  def change
    add_column :gp_category_categories, :group_code, :string
  end
end
