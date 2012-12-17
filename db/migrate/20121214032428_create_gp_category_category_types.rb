class CreateGpCategoryCategoryTypes < ActiveRecord::Migration
  def change
    create_table :gp_category_category_types do |t|
      t.integer    :unid
      t.references :content

      t.references :concept
      t.references :layout

      t.string     :state
      t.string     :name
      t.string     :title
      t.integer    :sort_no

      t.timestamps
    end
    add_index :gp_category_category_types, :content_id
    add_index :gp_category_category_types, :concept_id
    add_index :gp_category_category_types, :layout_id
  end
end
