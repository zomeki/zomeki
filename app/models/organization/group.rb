class Organization::Group < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Base::Page::Publisher

  include Cms::Model::Auth::Content

  attr_accessible :state, :name, :sys_group_code, :sitemap_state, :docs_order, :sort_no,
                  :business_outline, :contact_information, :outline,
                  :concept_id, :layout_id, :more_layout_id, :in_creator

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'display_published_at DESC, published_at DESC'],
                        ['公開日（昇順）', 'display_published_at ASC, published_at ASC']]

  default_scope { order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no") }
  scope :public, -> { where(state: 'public') }
  scope :none, -> { where("#{self.table_name}.id IS ?", nil).where("#{self.table_name}.id IS NOT ?", nil) }

  # Page
  belongs_to :concept, :class_name => 'Cms::Concept'
  belongs_to :layout, :class_name => 'Cms::Layout'
  belongs_to :more_layout, :class_name => 'Cms::Layout'

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Organization::Content::Group'
  validates_presence_of :content_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  belongs_to :sys_group, :foreign_key => :sys_group_code, :primary_key => :code, :class_name => 'Sys::Group'

  after_initialize :set_defaults

  validates :sys_group_code, :presence => true, :uniqueness => true
  validates :name, :presence => true, :format => /\A[0-9A-Za-z\._-]*\z/i
  validate :name_uniqueness_in_siblings

  def sitemap_state_text
    SITEMAP_STATE_OPTIONS.detect{|o| o.last == self.sitemap_state }.try(:first).to_s
  end

  def docs_order_text
    DOCS_ORDER_OPTIONS.detect{|o| o.last == self.docs_order }.try(:first).to_s
  end

  def public?
    state == 'public'
  end

  def public_uri
    return '' unless content.public_node
    "#{content.public_node.public_uri}#{path_from_root}/"
  end

  def public_full_uri
    return '' unless content.public_node
    "#{content.public_node.public_full_uri}#{path_from_root}/"
  end

  def parent
    content.groups.where(sys_group_code: sys_group.parent.code).first
  end

  def ancestors(groups=[])
    parent.ancestors(groups) if parent
    groups << self
  end

  def path_from_root
    ancestors.map(&:name).join('/')
  end

  def children
    sys_group_codes = sys_group.children.pluck(:code)
    content.groups.where(sys_group_code: sys_group_codes)
  end

  def public_children
    children.public
  end

  def descendants(groups=[])
    groups << self
    children.each{|c| c.descendants(groups) } unless children.empty?
    return groups
  end

  def public_descendants(groups=[])
    return groups unless self.public?
    groups << self
    children.each{|c| c.public_descendants(groups) } unless children.empty?
    return groups
  end

  def bread_crumbs(public_node)
    crumbs = []

    if (node = content.try(:public_node))
      c = node.bread_crumbs.crumbs.first
      ancestors.each{|a| c << [a.sys_group.name, "#{node.public_uri}#{a.path_from_root}/"] }
      crumbs << c
    end

    if crumbs.empty?
      public_node.routes.each do |route|
        c = []
        route.each{|r| c << [r.title, r.public_uri] }
        crumbs << c
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def rebuild(content, options={})
    return false unless self.public?
    @save_mode = :publish
    publish_page(content, options)
  end

  def public_smart_phone_path
    return '' unless public_uri
    "#{content.site.public_path}/_smartphone#{public_uri}"
  end

  private

  def set_defaults
    self.state = STATE_OPTIONS.first.last if self.has_attribute?(:state) && self.state.nil?
    self.sitemap_state = SITEMAP_STATE_OPTIONS.first.last if self.has_attribute?(:sitemap_state) && self.sitemap_state.nil?
    self.docs_order = DOCS_ORDER_OPTIONS.first.last if self.has_attribute?(:docs_order) && self.docs_order.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end

  def name_uniqueness_in_siblings
    siblings = parent ? parent.children : content.root_groups
    errors.add(:name, :taken) unless siblings.where(name: name).where('id != ?', id).empty?
  end
end
