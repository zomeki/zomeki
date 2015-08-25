class AddEventWillSyncToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :event_will_sync, :string
  end
end
