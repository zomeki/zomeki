class AddNameToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :name, :string
  end
end
