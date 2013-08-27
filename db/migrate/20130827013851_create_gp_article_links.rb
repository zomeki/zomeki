class CreateGpArticleLinks < ActiveRecord::Migration
  def change
    create_table :gp_article_links do |t|
      t.belongs_to :doc

      t.string :body
      t.string :url

      t.timestamps
    end
  end
end
