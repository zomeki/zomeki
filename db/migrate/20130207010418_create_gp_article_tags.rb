class CreateGpArticleTags < ActiveRecord::Migration
  def change
    create_table :gp_article_tags do |t|
      t.integer :unid
      t.string  :name
      t.text    :word

      t.timestamps
    end
  end
end
