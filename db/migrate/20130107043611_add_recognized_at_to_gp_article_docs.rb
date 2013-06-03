class AddRecognizedAtToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :recognized_at, :datetime
  end
end
