class AddPrevEditionIdToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :prev_edition_id, :integer
  end
end
