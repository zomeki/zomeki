class ChangeListImageOnGpArticleDocs < ActiveRecord::Migration
  def up
    change_column :gp_article_docs, :list_image, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
