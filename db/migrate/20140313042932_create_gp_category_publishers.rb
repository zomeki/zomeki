class CreateGpCategoryPublisheres < ActiveRecord::Migration
  def change
    create_table :gp_category_publisheres do |t|
      t.belongs_to :category

      t.timestamps
    end
    add_index :gp_category_publisheres, :category_id
  end
end
