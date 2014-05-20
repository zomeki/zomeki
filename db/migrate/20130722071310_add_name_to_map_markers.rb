class AddNameToMapMarkers < ActiveRecord::Migration
  def change
    add_column :map_markers, :name, :string
  end
end
