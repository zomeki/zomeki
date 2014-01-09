class CreateToolConvertSettings < ActiveRecord::Migration
  def change
    create_table :tool_convert_settings do |t|
      t.string :site_url
      t.text :title_tag
      t.text :body_tag

      t.timestamps
    end

    add_index :tool_convert_settings, :site_url
  end
end
