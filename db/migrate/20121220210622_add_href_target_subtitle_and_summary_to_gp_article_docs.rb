class AddHrefTargetSubtitleAndSummaryToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :href, :string
    add_column :gp_article_docs, :target, :string
    add_column :gp_article_docs, :subtitle, :string
    add_column :gp_article_docs, :summary, :string
  end
end
