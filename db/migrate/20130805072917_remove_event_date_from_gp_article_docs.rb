class RemoveEventDateFromGpArticleDocs < ActiveRecord::Migration
  def up
    GpArticle::Doc.all.each do |doc|
      doc.update_column(:event_started_on, doc.event_date)
      doc.update_column(:event_ended_on, doc.event_date)
    end
    remove_column :gp_article_docs, :event_date
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
