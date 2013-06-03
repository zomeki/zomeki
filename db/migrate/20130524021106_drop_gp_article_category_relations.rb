class DropGpArticleCategoryRelations < ActiveRecord::Migration
  def up
    drop_table :gp_article_category_types
    drop_table :gp_article_categories
    drop_table :gp_article_categories_gp_article_docs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
