class CreateGpArticleCategoriesGpArticleDocsJoinTable < ActiveRecord::Migration
  def change
    create_table :gp_article_categories_gp_article_docs, :id => false do |t|
      t.integer :category_id
      t.integer :doc_id
    end
  end
end
