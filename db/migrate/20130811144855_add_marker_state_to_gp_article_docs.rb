class AddMarkerStateToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :marker_state, :string
  end
end
