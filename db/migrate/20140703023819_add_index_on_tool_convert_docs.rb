class AddIndexOnToolConvertDocs < ActiveRecord::Migration
  def change
    add_index :tool_convert_docs, :content_id
    add_index :tool_convert_docs, [:docable_id, :docable_type]
    add_index :tool_convert_docs, :uri_path, :length => 255
  end
end
