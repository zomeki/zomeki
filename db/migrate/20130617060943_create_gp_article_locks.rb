class CreateGpArticleLocks < ActiveRecord::Migration
  def change
    create_table :gp_article_locks do |t|
      t.string :lockable_type
      t.integer :lockable_id

      t.references :user

      t.timestamps
    end
  end
end
