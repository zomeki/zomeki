class AddSppTargetToCmsSites < ActiveRecord::Migration
  def change
    add_column :cms_sites, :spp_target, :string
  end
end
