class CreateGnavCategorySets < ActiveRecord::Migration
  def change
    create_table :gnav_category_sets do |t|
      t.references :menu_item
      t.references :category
      t.string     :layer
    end
    add_index :gnav_category_sets, :menu_item_id
    add_index :gnav_category_sets, :category_id
  end
end
