class CreateGpArticleDocs < ActiveRecord::Migration
  def change
    create_table :gp_article_docs do |t|
      t.integer    :unid
      t.references :concept
      t.references :content

      t.string     :title

      t.timestamps
    end
  end
end
