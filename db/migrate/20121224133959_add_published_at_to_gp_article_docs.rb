class AddPublishedAtToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :published_at, :datetime
  end
end
