class AddTemplateIdToGpCategoryCategoryTypes < ActiveRecord::Migration
  def change
    add_column :gp_category_category_types, :template_id, :integer
  end
end
