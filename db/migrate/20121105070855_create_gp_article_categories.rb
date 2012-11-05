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
  end
end
