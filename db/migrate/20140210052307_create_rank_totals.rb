class CreateRankTotals < ActiveRecord::Migration
  def change
    create_table :rank_totals do |t|
      t.references :content

      t.string  :term
      t.integer :category_id

      t.string  :page_title
      t.string  :hostname
      t.string  :page_path
      t.integer :pageviews
      t.integer :visitors

      t.timestamps
    end
  end
end
