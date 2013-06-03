class RemoveStateFromAdBannerGroups < ActiveRecord::Migration
  def up
    remove_column :ad_banner_groups, :state
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
