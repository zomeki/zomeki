class AddRelDocIdsToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :rel_doc_ids, :string
  end
end
