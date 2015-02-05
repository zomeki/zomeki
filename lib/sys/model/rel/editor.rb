module Sys::Model::Rel::Editor
  def self.included(mod)
    mod.has_many :editors, :foreign_key => 'parent_unid', :class_name => 'Sys::Editor',
      :primary_key => 'unid', :dependent => :destroy, :order => 'updated_at DESC, created_at DESC'
    
    mod.after_save :save_editor
  end

  def last_editor
    return nil if editors.empty?
    editors.first
  end
  
  def save_editor
    return false unless unid

    return false if Core.user_group.blank? || Core.user.blank?

    _editor = editors.build
    _editor.parent_unid = unid
    _editor.created_at  = Core.now
    _editor.updated_at  = Core.now
    _editor.group_id    = Core.user_group.id
    _editor.user_id     = Core.user.id
    return false unless _editor.save
    
    return true
  end
end
