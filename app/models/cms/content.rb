# encoding: utf-8
class Cms::Content < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Content
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  has_many   :settings, :foreign_key => :content_id, :class_name => 'Cms::ContentSetting',
    :order => :sort_no, :dependent => :destroy
    
  attr_accessor :in_settings
  
  validates_presence_of :state, :model, :name

  after_save :save_settings
  
  def in_settings
    unless read_attribute(:in_settings)
      values = {}
      settings.each do |st|
        if st.sort_no
          values[st.name] ||= {}
          values[st.name][st.sort_no] = value
        else
          values[st.name] = st.value
        end
      end
      write_attribute(:in_settings, values)
    end
    read_attribute(:in_settings)
  end
  
  def in_settings=(values)
    write_attribute(:in_settings, values)
  end
  
  def locale(name)
    model = self.class.to_s.underscore
    label = ''
    if model != 'cms/content'
      label = I18n.t name, :scope => [:activerecord, :attributes, model]
      return label if label !~ /^translation missing:/
    end
    label = I18n.t name, :scope => [:activerecord, :attributes, 'cms/content']
    return label =~ /^translation missing:/ ? name.to_s.humanize : label
  end
  
  def states
    [['公開','public']]
  end

  def node_is(node)
    node = Cms::Node.find(:first, :conditions => {:id => node}) if node.class != Cms::Node
    self.and :id, node.content_id if node
  end
  
  def new_setting(name = nil)
    Cms::ContentSetting.new({:content_id => id, :name => name.to_s})
  end
  
  def setting_value(name)
    st = settings.find(:first, :conditions => {:name => name.to_s})
    st ? st.value : nil
  end

  def setting_extra_value(name)
    settings.find_by_name(name).try(:extra_value)
  end

protected
  def save_settings
    in_settings.each do |name, value|
      st = settings.find(:first, :conditions => {:name => name}) || new_setting(name)
      st.value = value
      st.save if st.changed?
    end
    return true
  end
end
