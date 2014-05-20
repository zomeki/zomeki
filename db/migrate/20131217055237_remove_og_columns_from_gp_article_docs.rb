class RemoveOgColumnsFromGpArticleDocs < ActiveRecord::Migration
  def up
    remove_column :gp_article_docs, :og_description_use_body
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
