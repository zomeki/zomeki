class AddRecursiveLevelToToolConvertDownload < ActiveRecord::Migration
  def change
    add_column :tool_convert_downloads, :recursive_level, :integer, :after => :end_at
  end
end
