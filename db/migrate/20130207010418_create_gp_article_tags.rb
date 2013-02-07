class CreateGpArticleTags < ActiveRecord::Migration
  def change
    create_table :gp_article_tags do |t|
      t.references :content

      t.integer :unid
      t.string  :name
      t.text    :word

      t.timestamps
    end
    add_index :gp_article_tags, :content_id
  end
end
