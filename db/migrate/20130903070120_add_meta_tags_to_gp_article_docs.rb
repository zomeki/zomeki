class AddMetaTagsToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :meta_description, :text
    add_column :gp_article_docs, :meta_keywords, :string
  end
end
