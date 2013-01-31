class AddEventStateAndEventDateToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :event_state, :string
    add_column :gp_article_docs, :event_date, :date
  end
end
