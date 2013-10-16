class AddImageToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :list_image, :integer
  end
end
