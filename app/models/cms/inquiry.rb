class Cms::Inquiry < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :group, :foreign_key => :group_id, :class_name => 'Sys::Group'

  #before_save :set_group

  #validates_presence_of :unid

  def visible?
    return state == 'visible'
  end

  def set_group
    self.group_id = Core.user_group.id unless group_id
  end

  def address
    group.address if group
  end

  def group_id
    group.id if group
  end

  def tel
    group.tel if group
  end

  def tel_attend
    group.tel_attend if group
  end

  def fax
    group.fax if group
  end

  def email
    group.email if group
  end

  def note
    group.note if group
  end

end
