class AddKeepDisplayUpdatedAtToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :keep_display_updated_at, :boolean
  end
end
