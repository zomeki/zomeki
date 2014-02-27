class AddMoreLayoutIdToOrganizationGroups < ActiveRecord::Migration
  def change
    add_column :organization_groups, :more_layout_id, :integer
  end
end
