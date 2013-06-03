class CreateGpArticleDocs < ActiveRecord::Migration
  def change
    create_table :gp_article_docs do |t|
      t.integer    :unid
      t.references :concept
      t.references :content

      t.string     :title
      t.text       :body

      t.timestamps
    end
    add_index :gp_article_docs, :concept_id
    add_index :gp_article_docs, :content_id
  end
end
