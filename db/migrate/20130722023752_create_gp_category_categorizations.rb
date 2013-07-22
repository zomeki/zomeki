class CreateGpCategoryCategorizations < ActiveRecord::Migration
  def change
    create_table :gp_category_categorizations do |t|
      t.belongs_to :categorizable, polymorphic: true

      t.references :category

      t.timestamps
    end
  end
end
