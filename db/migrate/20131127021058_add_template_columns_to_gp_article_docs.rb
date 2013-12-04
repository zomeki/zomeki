class AddTemplateColumnsToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :template_id, :integer
    add_column :gp_article_docs, :template_values, :text
  end
end
