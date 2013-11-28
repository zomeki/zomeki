class AddOgColumnsToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :og_type, :string
    add_column :gp_article_docs, :og_title, :string
    add_column :gp_article_docs, :og_description, :text
    add_column :gp_article_docs, :og_description_use_body, :boolean
    add_column :gp_article_docs, :og_image, :string
  end
end
