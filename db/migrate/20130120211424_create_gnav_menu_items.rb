class CreateGnavMenuItems < ActiveRecord::Migration
  def change
    create_table :gnav_menu_items do |t|
      t.integer    :unid
      t.references :content

      t.references :concept

      t.string     :state
      t.string     :name
      t.string     :title
      t.integer    :sort_no

      t.timestamps
    end
    add_index :gnav_menu_items, :content_id
    add_index :gnav_menu_items, :concept_id
  end
end
