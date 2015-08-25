class AddOutlineToOrganizationGroups < ActiveRecord::Migration
  def change
    add_column :organization_groups, :outline, :text
  end
end
