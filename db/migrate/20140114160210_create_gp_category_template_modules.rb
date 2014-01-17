class CreateGpCategoryTemplateModules < ActiveRecord::Migration
  def change
    create_table :gp_category_template_modules do |t|
      t.belongs_to :content
      t.string :name
      t.string :title
      t.string :module_type
      t.string :module_type_mode

      t.string :wrapper_tag
      t.text :doc_style
      t.integer :num_docs

      t.timestamps
    end
    add_index :gp_category_template_modules, :content_id
  end
end
