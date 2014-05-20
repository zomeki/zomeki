class CreateGpTemplateItems < ActiveRecord::Migration
  def change
    create_table :gp_template_items do |t|
      t.belongs_to :template
      t.string     :state
      t.string     :name
      t.string     :title
      t.string     :item_type
      t.text       :item_options
      t.string     :style_attribute
      t.integer    :sort_no

      t.timestamps
    end
    add_index :gp_template_items, :template_id
  end
end
