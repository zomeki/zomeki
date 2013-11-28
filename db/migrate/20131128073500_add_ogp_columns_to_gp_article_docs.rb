class AddOgpColumnsToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :ogp_type, :string
    add_column :gp_article_docs, :ogp_title, :string
    add_column :gp_article_docs, :ogp_description, :text
    add_column :gp_article_docs, :ogp_description_use_body, :boolean
    add_column :gp_article_docs, :ogp_image, :string
  end
end
