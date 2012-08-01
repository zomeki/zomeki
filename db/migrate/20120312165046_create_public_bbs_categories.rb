class CreatePublicBbsCategories < ActiveRecord::Migration
  def change
    create_table :public_bbs_categories do |t|
      t.integer :unid
      t.string :state
      t.references :concept
      t.references :content
      t.references :layout

      t.integer :level_no, :null => false
      t.integer :sort_no
      t.integer :parent_id
      t.string :name
      t.string :title

      t.timestamps
    end
    add_index :public_bbs_categories, :content_id
  end
end
