class AddDocableColumnsToToolConvertDocs < ActiveRecord::Migration
  def change
    add_column :tool_convert_docs, :content_id, :integer, :after => :id
    add_column :tool_convert_docs, :docable_id, :integer, :after => :content_id
    add_column :tool_convert_docs, :docable_type, :string, :after => :docable_id
    add_column :tool_convert_docs, :doc_name, :text, :after => :docable_type
    add_column :tool_convert_docs, :doc_public_uri, :text, :after => :doc_name
    Tool::ConvertDoc.all.each do |cdoc|
      if doc = cdoc.doc_class.constantize.find_by_name(cdoc.name)
        cdoc.update_column(:content_id, doc.content_id)
        cdoc.update_column(:docable_id, doc.id)
        cdoc.update_column(:docable_type, cdoc.doc_class)
        cdoc.update_column(:doc_name, doc.name)
        cdoc.update_column(:doc_public_uri, doc.public_uri)
      end
    end
    change_column :tool_convert_docs, :published_at, :datetime, :after => :body
    remove_column :tool_convert_docs, :doc_class
    remove_column :tool_convert_docs, :name
  end
end
