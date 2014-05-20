class AddInternalCategoryTypeIdToGpCategoryCategoryTypes < ActiveRecord::Migration
  def change
    add_column :gp_category_category_types, :internal_category_type_id, :integer
  end
end
