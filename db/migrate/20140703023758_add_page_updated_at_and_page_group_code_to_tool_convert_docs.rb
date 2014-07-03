class AddPageUpdatedAtAndPageGroupCodeToToolConvertDocs < ActiveRecord::Migration
  def change
    add_column :tool_convert_docs, :page_updated_at, :string, :after => :body
    add_column :tool_convert_docs, :page_group_code, :string, :after => :page_updated_at
    Tool::ConvertDoc.find_each do |item|
      item.page_updated_at = item.published_at.strftime('%Y-%m-%d') if item.published_at
      item.page_group_code = item.uri_path.scan(/soshiki\/(\d+)\//)[0][0] rescue nil
      item.save
    end
  end
end
