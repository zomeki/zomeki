class CreateToolConvertImports < ActiveRecord::Migration
  def up
    create_table :tool_convert_imports do |t|
      t.string     :state
      t.text       :site_url
      t.string     :site_filename
      t.integer    :content_id
      t.integer    :overwrite
      t.datetime   :start_at
      t.datetime   :end_at
      t.text       :message
      t.integer    :total_num
      t.integer    :created_num
      t.integer    :updated_num
      t.integer    :nonupdated_num
      t.integer    :skipped_num
      t.integer    :link_total_num
      t.integer    :link_processed_num
      t.timestamps
    end
  end

  def down
    drop_table :tool_convert_imports
  end
end
