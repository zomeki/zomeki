class AddAroundTextToGpCategoryTemplateModules < ActiveRecord::Migration
  def change
    add_column :gp_category_template_modules, :upper_text, :text
    add_column :gp_category_template_modules, :lower_text, :text
  end
end
