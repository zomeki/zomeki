class ChangeHostAndUriPathOnToolConvertDocs < ActiveRecord::Migration
  def change
    change_column :tool_convert_docs, :host, :text, :after => :doc_public_uri
    change_column :tool_convert_docs, :uri_path, :text
    rename_column :tool_convert_docs, :host, :site_url
  end
end
