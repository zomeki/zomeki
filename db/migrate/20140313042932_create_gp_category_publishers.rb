class CreateGpCategoryPublishers < ActiveRecord::Migration
  def change
    create_table :gp_category_publishers do |t|
      t.belongs_to :category

      t.timestamps
    end
    add_index :gp_category_publishers, :category_id
  end
end
