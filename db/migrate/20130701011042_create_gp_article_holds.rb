class CreateGpArticleHolds < ActiveRecord::Migration
  def change
    create_table :gp_article_holds do |t|
      t.belongs_to :holdable, polymorphic: true

      t.references :user

      t.timestamps
    end
  end
end
