class DropGpArticleDocsGpCategoryCategoriesJoinTable < ActiveRecord::Migration
  def up
    rows = ActiveRecord::Base.connection.select <<-SQL
        SELECT doc_id AS categorizable_id, 'GpArticle::Doc' AS categorizable_type, category_id
          FROM gp_article_docs_gp_category_categories
      SQL
    rows.each {|row| GpCategory::Categorization.create!(row) }

    drop_table :gp_article_docs_gp_category_categories
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
