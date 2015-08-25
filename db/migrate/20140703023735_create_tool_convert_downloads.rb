class CreateToolConvertDownloads < ActiveRecord::Migration
  def up
    create_table :tool_convert_downloads do |t|
      t.string     :state
      t.text       :site_url
      t.text       :include_dir
      t.datetime   :start_at
      t.datetime   :end_at
      t.string     :remark
      t.text       :message
      t.timestamps
    end
  end

  def down
    drop_table :tool_convert_downloads
  end
end
