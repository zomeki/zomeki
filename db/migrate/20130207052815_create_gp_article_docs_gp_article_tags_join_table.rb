class CreateGpArticleDocsGpArticleTagsJoinTable < ActiveRecord::Migration
  def change
    create_table :gp_article_docs_gp_article_tags, :id => false do |t|
      t.integer :doc_id
      t.integer :tag_id
    end
  end
end
