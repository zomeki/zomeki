class AddDisplayDatesToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :display_published_at, :datetime
    add_column :gp_article_docs, :display_updated_at, :datetime
  end
end
