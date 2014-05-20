class AddSortNoToGpCategoryCategorizations < ActiveRecord::Migration
  def change
    add_column :gp_category_categorizations, :sort_no, :integer
  end
end
