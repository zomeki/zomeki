class ChangeBodyOnGpArticleDocs < ActiveRecord::Migration
  def up
    change_column :gp_article_docs, :body, :text, :limit => 16777215
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
