class CreateMapMarkers < ActiveRecord::Migration
  def change
    create_table :map_markers do |t|
      t.integer    :unid
      t.references :content

      t.string     :state
      t.string     :title
      t.string     :latitude
      t.string     :longitude
      t.text       :window_text

      t.timestamps
    end
  end
end
