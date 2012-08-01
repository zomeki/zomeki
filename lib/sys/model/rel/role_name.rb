# encoding: utf-8
module Sys::Model::Rel::RoleName
  def self.included(mod)
    mod.after_save :save_user_roles
  end

  attr_accessor :in_role_name_ids
  
  def in_role_name_ids
    unless read_attribute(:in_role_name_ids)
      value = role_names ? role_names.collect{|c| c.id}.join(' ') : ''
      write_attribute(:in_role_name_ids, value.to_s)
    end
    read_attribute(:in_role_name_ids)
  end
  
  def in_role_name_ids=(value)
    @_in_role_name_ids_changed = true
    write_attribute(:in_role_name_ids, value.to_s)
  end
  
private
  def save_user_roles
    return true unless @_in_role_name_ids_changed
    return false if @sent_save_user_roles
    @sent_save_user_roles = true
    
    in_ids = []
    in_role_name_ids.split(' ').uniq.each{|id| in_ids << id.to_i if !id.blank?}
    
    Sys::UsersRole.find(:all, :conditions => {:user_id => id}).each do |rel|
      if in_ids.index(rel.role_id)
        in_ids.delete(rel.role_id)
      else
        rel.destroy
      end
    end
    
    in_ids.each do |role_id|
      Sys::UsersRole.new({
        :user_id => self.id,
        :role_id => role_id,
      }).save
    end
    
    role_names(true)
    return true
  end
end