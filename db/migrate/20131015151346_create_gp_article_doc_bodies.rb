class CreateGpArticleDocBodies < ActiveRecord::Migration
  def change
    create_table :gp_article_doc_bodies do |t|
      t.belongs_to :doc
      t.text :body

      t.timestamps
    end
    add_index :gp_article_doc_bodies, :doc_id
  end
end
