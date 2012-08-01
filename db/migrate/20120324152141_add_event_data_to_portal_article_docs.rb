class AddEventDataToPortalArticleDocs < ActiveRecord::Migration
  def change
    add_column :portal_article_docs, :event_state, :string
    add_column :portal_article_docs, :event_date, :date
  end
end
