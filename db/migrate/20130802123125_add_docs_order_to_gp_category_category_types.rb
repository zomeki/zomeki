class AddDocsOrderToGpCategoryCategoryTypes < ActiveRecord::Migration
  def change
    add_column :gp_category_category_types, :docs_order, :string
  end
end
