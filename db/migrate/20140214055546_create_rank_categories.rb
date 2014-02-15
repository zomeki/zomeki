class CreateRankCategories < ActiveRecord::Migration
  def change
    remove_column :rank_totals, :category_id

    create_table :rank_categories do |t|
      t.references :content
      t.string     :page_path
      t.references :category

      t.timestamps
    end
  end
end
