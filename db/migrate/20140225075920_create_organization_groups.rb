class CreateOrganizationGroups < ActiveRecord::Migration
  def change
    create_table :organization_groups do |t|
      t.integer :unid
      t.belongs_to :concept
      t.belongs_to :layout

      t.belongs_to :content
      t.string :state
      t.string :name
      t.string :sys_group_code
      t.string :sitemap_state
      t.string :docs_order
      t.integer :sort_no

      t.timestamps
    end
    add_index :organization_groups, :sys_group_code
  end
end
