class AddRawTagsToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :raw_tags, :text
  end
end
