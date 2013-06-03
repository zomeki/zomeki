class AddStateToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :state, :string
  end
end
