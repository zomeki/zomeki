module Sys::Model::Rel::Editor
  def self.included(mod)
    mod.has_many :editors, :foreign_key => 'parent_unid', :class_name => 'Sys::Editor',
      :primary_key => 'unid', :dependent => :destroy, :order => 'updated_at DESC, created_at DESC'

    mod.has_one :last_editor, :foreign_key => 'parent_unid', :class_name => 'Sys::Editor',
      :primary_key => 'unid', :dependent => :destroy, :conditions => "last_is = 1"
    
    mod.after_save :save_editor
  end

  def skip_editor_save(skip=true)
    @skip_save = skip
  end

  def skip_editor_save?
    @skip_save
  end

  def save_editor
    return false unless unid
    return false if skip_editor_save?

    return false if Core.user_group.blank? || Core.user.blank?
    
    last_editor.update_column(:last_is, 0) if last_editor

    _editor = editors.build
    _editor.parent_unid = unid
    _editor.created_at  = Core.now
    _editor.updated_at  = Core.now
    _editor.group_id    = Core.user_group.id
    _editor.user_id     = Core.user.id
    _editor.last_is     = 1
    return false unless _editor.save
    
    last_editor = editors.where(last_is: 1).first
    
    return true
  end
end
