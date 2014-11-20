# encoding: utf-8
class Cms::Piece < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Piece
  include Cms::Model::Base::Page::Publisher
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::UnidRelation
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status,   :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  has_many   :settings, :foreign_key => :piece_id,   :class_name => 'Cms::PieceSetting',
    :order => :sort_no, :dependent => :destroy

  attr_accessor :in_settings
  attr_accessor :setting_save_skip
  
  validates_presence_of :state, :model, :name, :title
  validates_uniqueness_of :name, :scope => :concept_id,
    :if => %Q(!replace_page?)
  validates_format_of :name, :with => /^[0-9a-zA-Z\-_]+$/, :if => "!name.blank?",
    :message => "は半角英数字、ハイフン、アンダースコアで入力してください。"
  
  after_save :save_settings
  after_save :replace_new_piece
  
  def replace_new_piece
    if state == "public" && rep = replaced_page
      rep.destroy
    end
    return true
  end

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

  def setting_extra_values(name)
    settings.find_by_name(name).try(:extra_values) || {}.with_indifferent_access
  end

  def setting_extra_value(name, extra_name)
    setting_extra_values(name)[extra_name]
  end

  def duplicate(rel_type = nil)
    item = self.class.new(self.attributes)
    item.id            = nil
    item.unid          = nil
    item.created_at    = nil
    item.updated_at    = nil
    item.recognized_at = nil
    item.published_at  = nil

    if rel_type == nil
      item.name  = nil
      item.title = item.title.gsub(/^(【複製】)*/, "【複製】")
    elsif rel_type == :replace
      item.state = "closed"
    end

    item.setting_save_skip = true
    return false unless item.save(:validate => false)

    # piece_settings
    settings.each do |setting|
      dupe_setting = Cms::PieceSetting.new(setting.attributes)
      dupe_setting.piece_id   = item.id
      dupe_setting.created_at = nil
      dupe_setting.updated_at = nil
      dupe_setting.save(:validate => false)
    end

    if rel_type == :replace
      rel = Sys::UnidRelation.new
      rel.unid     = item.unid
      rel.rel_unid = self.unid
      rel.rel_type = 'replace'
      rel.save
    end

    return item
  end
  
protected
  def save_settings
    return true if setting_save_skip
    
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
