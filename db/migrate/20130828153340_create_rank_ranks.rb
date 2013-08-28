class CreateRankRanks < ActiveRecord::Migration
  def change
    create_table :rank_ranks do |t|
      t.references :content

      t.string  :page_title
      t.string  :hostname
      t.string  :page_path
      t.date    :date
      t.integer :pageviews
      t.integer :visitors

      t.timestamps
    end
  end
end
