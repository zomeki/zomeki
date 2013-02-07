class AddLastTaggedAtToGpArticleTags < ActiveRecord::Migration
  def change
    add_column :gp_article_tags, :last_tagged_at, :datetime
  end
end
