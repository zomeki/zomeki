class CreateGpCategoryTemplates < ActiveRecord::Migration
  def change
    create_table :gp_category_templates do |t|
      t.belongs_to :content
      t.string :name
      t.string :title
      t.text :body

      t.timestamps
    end
    add_index :gp_category_templates, :content_id
  end
end
