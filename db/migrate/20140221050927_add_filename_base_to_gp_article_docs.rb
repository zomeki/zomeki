class AddFilenameBaseToGpArticleDocs < ActiveRecord::Migration
  def up
    add_column :gp_article_docs, :filename_base, :string
    GpArticle::Doc.where(filename_base: nil).update_all(filename_base: 'index')
  end

  def down
    remove_column :gp_article_docs, :filename_base
  end
end
