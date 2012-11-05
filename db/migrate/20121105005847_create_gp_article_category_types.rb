class CreateGpArticleCategoryTypes < ActiveRecord::Migration
  def change
    create_table :gp_article_category_types do |t|
      t.integer    :unid
      t.references :concept
      t.references :content

      t.string  :name
      t.string  :kana
      t.string  :slug
      t.integer :display_order
    end
  end
end
