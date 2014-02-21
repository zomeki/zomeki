class AddFilenameBaseToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :filename_base, :string
  end
end
