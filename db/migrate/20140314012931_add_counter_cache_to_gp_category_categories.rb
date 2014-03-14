class AddCounterCacheToGpCategoryCategories < ActiveRecord::Migration
  def up
    add_column :gp_category_categories, :children_count, :integer, :null => false, :default => 0

    GpCategory::Category.all.each do |category|
      GpCategory::Category.update_counters(category.id, :children_count => category.children.count)
    end
  end

  def down
    remove_column :gp_category_categories, :children_count
  end
end
