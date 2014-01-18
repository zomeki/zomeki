class AddFeaturesToGpArticleDocs < ActiveRecord::Migration
  def up
    add_column :gp_article_docs, :feature_1, :boolean
    add_column :gp_article_docs, :feature_2, :boolean

    GpArticle::Doc.update_all feature_1: true, feature_2: true
  end

  def down
    remove_column :gp_article_docs, :feature_2
    remove_column :gp_article_docs, :feature_1
  end
end
