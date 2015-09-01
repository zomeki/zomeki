class AddLastIsToSysEditors < ActiveRecord::Migration
  def change
    add_column :sys_editors, :last_is, :integer

    Sys::Editor.update_all(last_is: 0)
    GpArticle::Doc.unscoped.all.each do |doc|
      unless doc.editors.empty?
        last_editor = doc.editors.first
        last_editor.update_column(:last_is, 1)
      else
        editor = Sys::Editor.new
        editor.parent_unid = doc.unid
        editor.created_at  = Core.now
        editor.updated_at  = Core.now
        editor.last_is     = 1
        if doc.creator
          editor.group_id = doc.creator.group_id
          editor.user_id  = doc.creator.user_id
        end
        editor.save
      end
    end
    
  end
end
