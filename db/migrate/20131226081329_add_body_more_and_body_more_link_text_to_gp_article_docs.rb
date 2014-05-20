class AddBodyMoreAndBodyMoreLinkTextToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :body_more, :text
    add_column :gp_article_docs, :body_more_link_text, :string
  end
end
