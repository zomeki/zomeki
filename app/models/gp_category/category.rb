# encoding: utf-8
class GpCategory::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Tree
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'display_published_at DESC, published_at DESC'], ['公開日（昇順）', 'display_published_at ASC, published_at ASC']]

  default_scope { order("#{self.table_name}.category_type_id, #{self.table_name}.parent_id, #{self.table_name}.level_no, #{self.table_name}.sort_no, #{self.table_name}.name") }

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :layout,  :foreign_key => :layout_id,  :class_name => 'Cms::Layout'
  belongs_to :template

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  belongs_to :category_type, :foreign_key => :category_type_id, :class_name => 'GpCategory::CategoryType'
  validates_presence_of :category_type_id

  belongs_to :parent, :foreign_key => :parent_id, :class_name => self.name, :counter_cache => :children_count
  has_many :children, :foreign_key => :parent_id, :class_name => self.name, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:scope => [:category_type_id, :parent_id]}
  validates :title, :presence => true

  has_and_belongs_to_many :events, :class_name => 'GpCalendar::Event', :join_table => 'gp_calendar_events_gp_category_categories', :order => 'started_on, ended_on'

  has_many :categorizations, :dependent => :destroy
  has_many :docs, :through => :categorizations, :source => :categorizable, :source_type => 'GpArticle::Doc'
  has_many :markers, :through => :categorizations, :source => :categorizable, :source_type => 'Map::Marker'
  has_many :publishers, :dependent => :destroy
  has_many :category_sets, :class_name => 'Gnav::CategorySet', :dependent => :destroy

  belongs_to :group, :foreign_key => :group_code, :class_name => 'Sys::Group'

  after_initialize :set_defaults

  before_validation :set_attributes_from_parent

  scope :public, where(state: 'public')
  scope :none, -> { where("#{self.table_name}.id IS ?", nil).where("#{self.table_name}.id IS NOT ?", nil) }

  after_destroy :clean_public_path

  def content
    category_type.content
  end

  def descendants(categories=[])
    categories << self
    children.includes(:children).each {|c| c.descendants(categories) } unless children.empty?
    return categories
  end

  def public_descendants(categories=[])
    return categories unless self.public?
    categories << self
    children.includes(:children).each {|c| c.public_descendants(categories) } unless children.empty?
    return categories
  end

  def descendants_for_option(categories=[])
    categories << ["#{'　　' * (level_no - 1)}#{title}", id]
    children.includes(:children).each {|c| c.descendants_for_option(categories) } unless children.empty?
    return categories
  end

  def ancestors(categories=[])
    parent.ancestors(categories) if parent
    categories << self
  end

  def path_from_root_category
    ancestors.map{|a| a.name }.join('/')
  end

  def bread_crumbs(category_type_node)
    crumbs = []

    if content
      if (node = content.category_type_node)
        c = node.bread_crumbs.crumbs.first
        c << [category_type.title, "#{node.public_uri}#{category_type.name}/"]
        ancestors.each {|a| c << [a.title, "#{node.public_uri}#{category_type.name}/#{a.path_from_root_category}/"] }
        crumbs << c
      end
    end

    if crumbs.empty?
      category_type_node.routes.each do |r|
        c = []
        r.each {|i| c << [i.title, i.public_uri] }
        crumbs << c
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def docs_with_categorization
    # There are 3 way to categorize (GpArticle::Doc, GpCalendar::Event, Map::Marker)
    t = categorizations.table
    docs_without_categorization.where(t[:categorized_as].eq('GpArticle::Doc'))
  end
  alias_method_chain :docs, :categorization

  def public_docs
    docs.order(inherited_docs_order).mobile(::Page.mobile?).public
  end

  def copy_from_group(group)
    group.children.each do |child_group|
      if (child = children.where(group_code: child_group.code).first)
        new_state = (child_group.state == 'disabled' ? 'closed' : 'public')
        child.update_attributes(state: new_state, name: child_group.name_en, title: child_group.name, sort_no: child_group.sort_no)
      else
        if (old_child = children.find_by_name(child_group.name_en))
          old_child.update_column(:name, "#{old_child.name}_#{old_child.id}")
        end
        child = children.create(group_code: child_group.code, name: child_group.name_en, title: child_group.name, sort_no: child_group.sort_no)
      end
      child.copy_from_group(child_group) unless child_group.children.empty?
    end
  end

  def public_children
    children.public
  end

  def sitemap_visible?
    self.sitemap_state == 'visible'
  end

  def public_path
    "#{category_type.public_path}#{path_from_root_category}/"
  end

  def public_uri
    "#{category_type.public_uri}#{path_from_root_category}/"
  end

  def public_full_uri
    "#{category_type.public_full_uri}#{path_from_root_category}/"
  end

  def inherited_docs_order
    return self.docs_order if self.docs_order.present?
    return parent.inherited_docs_order if parent
    category_type.docs_order
  end

  def unique_sort_key
    ancestors.inject('') {|k, a| k.concat('__%032d_%32s_%032d_%032d_%032d_%032d_%32s' % [a.category_type.sort_no.to_i, a.category_type.name.to_s,
                                                                                         a.category_type_id.to_i, a.parent_id.to_i, a.level_no.to_i, a.sort_no.to_i, a.name.to_s]) }
  end

  def inherited_template
    return self.template if self.template
    return parent.inherited_template if parent
    category_type.template
  end

  private

  def set_defaults
    self.state         = STATE_OPTIONS.first.last         if self.has_attribute?(:state) && self.state.nil?
    self.sitemap_state = SITEMAP_STATE_OPTIONS.first.last if self.has_attribute?(:sitemap_state) && self.sitemap_state.nil?
    self.docs_order    = DOCS_ORDER_OPTIONS.first.last    if self.has_attribute?(:docs_order) && self.docs_order.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end

  def set_attributes_from_parent
    if parent
      self.category_type = parent.category_type
      self.level_no = parent.level_no + 1
    else
      self.level_no = 1
    end
  end

  def clean_public_path
    FileUtils.rm_r(public_path) if public_path.present? && ::File.exist?(public_path)
  end
end
