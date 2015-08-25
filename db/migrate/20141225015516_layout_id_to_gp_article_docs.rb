class LayoutIdToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :layout_id, :integer
  end
end
