class CreateGpArticleDocsGpCategoryCategoriesJoinTable < ActiveRecord::Migration
  def change
    create_table :gp_article_docs_gp_category_categories, :id => false do |t|
      t.integer :doc_id
      t.integer :category_id
    end
  end
end
