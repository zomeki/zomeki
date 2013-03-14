# encoding: utf-8
class Cms::Piece < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Piece
  include Cms::Model::Base::Page::Publisher
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status,   :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  has_many   :settings, :foreign_key => :piece_id,   :class_name => 'Cms::PieceSetting',
    :order => :sort_no, :dependent => :destroy

  attr_accessor :in_settings
  
  validates_presence_of :state, :model, :name, :title
  validates_uniqueness_of :name, :scope => :concept_id
  validates_format_of :name, :with => /^[0-9a-zA-Z\-_]+$/, :if => "!name.blank?",
    :message => "は半角英数字、ハイフン、アンダースコアで入力してください。"
  
  after_save :save_settings
  
  def in_settings
    unless read_attribute(:in_settings)
      values = {}
      settings.each do |st|
        if st.sort_no
          values[st.name] ||= {}
          values[st.name][st.sort_no] = st.value
        else
          values[st.name] = st.value
        end
      end
      write_attribute(:in_settings, values)
    end
    read_attribute(:in_settings).with_indifferent_access
  end
  
  def in_settings=(values)
    write_attribute(:in_settings, values)
  end
  
  def locale(name)
    model = self.class.to_s.underscore
    label = ''
    if model != 'cms/piece'
      label = I18n.t name, :scope => [:activerecord, :attributes, model]
      return label if label !~ /^translation missing:/
    end
    label = I18n.t name, :scope => [:activerecord, :attributes, 'cms/piece']
    return label =~ /^translation missing:/ ? name.to_s.humanize : label
  end
  
  def node_is(node)
  	layout = nil
    node = Cms::Node.find(:first, :conditions => {:id => node}) if node.class != Cms::Node
    layout = node.inherited_layout if node
    self.and :id, 'IN', layout.pieces if layout
  end
  
  def css_id
    name.gsub(/-/, '_').camelize(:lower)
  end
  
  def css_attributes
    attr = ''
    
    attr += ' id="' + css_id + '"' if css_id != ''
    
    _cls = 'piece'
    attr += ' class="' + _cls + '"' if _cls != ''
    
    attr
  end
  
  def new_setting(name = nil)
    Cms::PieceSetting.new({:piece_id => id, :name => name.to_s})
  end
  
  def setting_value(name)
    st = settings.find(:first, :conditions => {:name => name.to_s})
    st ? st.value : nil
  end

protected
  def save_settings
    in_settings.each do |name, value|
      name = name.to_s
      
      if !value.is_a?(Hash)
        st = settings.find(:first, :conditions => ["name = ?", name]) || new_setting(name)
        st.value   = value
        st.sort_no = nil
        st.save if st.changed?
        next
      end
      
      _settings = settings.find(:all, :conditions => ["name = ?", name])
      value.each_with_index do |data, idx|
        st = _settings[idx] || new_setting(name)
        st.sort_no = data[0]
        st.value   = data[1]
        st.save if st.changed?
      end
      (_settings.size - value.size).times do |i|
        idx = value.size + i - 1
        _settings[idx].destroy
        _settings.delete_at(idx)
      end
    end
    return true
  end
end
