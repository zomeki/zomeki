class AddShareToSnsWithToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :share_to_sns_with, :string
  end
end
