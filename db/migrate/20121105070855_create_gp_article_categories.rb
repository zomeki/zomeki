class CreateGpArticleCategories < ActiveRecord::Migration
  def change
    create_table :gp_article_categories do |t|
      t.integer    :unid
      t.references :concept
      t.references :content

      t.references :category_type
      t.references :parent
      t.references :layout
      t.string     :state
      t.string     :name
      t.string     :title
      t.integer    :level_no
      t.integer    :sort_no

      t.timestamps
    end
    add_index :gp_article_categories, :concept_id
    add_index :gp_article_categories, :content_id
    add_index :gp_article_categories, :category_type_id
    add_index :gp_article_categories, :parent_id
    add_index :gp_article_categories, :layout_id
  end
end
