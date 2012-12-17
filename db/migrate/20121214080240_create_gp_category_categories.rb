class CreateGpCategoryCategories < ActiveRecord::Migration
  def change
    create_table :gp_category_categories do |t|
      t.integer    :unid

      t.references :concept
      t.references :layout

      t.references :category_type
      t.references :parent
      t.string     :state
      t.string     :name
      t.string     :title
      t.integer    :level_no
      t.integer    :sort_no
      t.string     :description

      t.timestamps
    end
    add_index :gp_category_categories, :concept_id
    add_index :gp_category_categories, :layout_id
    add_index :gp_category_categories, :category_type_id
    add_index :gp_category_categories, :parent_id
  end
end
