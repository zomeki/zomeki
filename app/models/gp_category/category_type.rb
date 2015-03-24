class GpCategory::CategoryType < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'display_published_at DESC, published_at DESC'], ['公開日（昇順）', 'display_published_at ASC, published_at ASC']]

  default_scope { joins(:content).includes(:content).order("#{self.table_name}.sort_no, #{self.table_name}.name") }

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCategory::Content::CategoryType'
  validates_presence_of :content_id

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :layout, :foreign_key => :layout_id,  :class_name => 'Cms::Layout'
  belongs_to :template
  belongs_to :internal_category_type, :class_name => self.name

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_many :categories, :foreign_key => :category_type_id, :class_name => 'GpCategory::Category', :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  after_initialize :set_defaults

  scope :public, -> { where(state: 'public') }
  scope :none, -> { where("#{self.table_name}.id IS ?", nil).where("#{self.table_name}.id IS NOT ?", nil) }

  after_destroy :clean_public_path

  def public_categories
    categories.public
  end

  def root_categories
    categories.where(parent_id: nil)
  end

  def root_categories_for_option
    root_categories.map {|c| [c.title, c.id] }
  end

  def public_root_categories
    root_categories.public
  end

  def categories_for_option
    root_categories.map{|c| c.descendants_for_option }.flatten(1)
  end

  def find_category_by_path_from_root_category(path_from_root_category)
    category_names = path_from_root_category.split('/')
    category_names.inject(root_categories.find_by_name(category_names.shift)) {|result, item|
      result.children.find_by_name(item)
    }
  end

  def public_path
    return '' unless node = content.public_node
    "#{node.public_path}#{name}/"
  end

  def public_uri
    return '' unless node = content.public_node
    "#{node.public_uri}#{name}/"
  end

  def public_full_uri
    return '' unless node = content.public_node
    "#{node.public_full_uri}#{name}/"
  end

  def bread_crumbs(category_type_node)
    crumbs = []

    if content
      if (node = content.category_type_node)
        c = node.bread_crumbs.crumbs.first
        c << [title, "#{node.public_uri}#{name}/"]
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

  def copy_from_groups(groups)
    categories.each {|c| c.update_attribute(:state, 'closed') }

    groups.each do |group|
      if (category = categories.where(parent_id: nil, group_code: group.code).first)
        new_state = (group.state == 'disabled' ? 'closed' : 'public')
        category.update_attributes(state: new_state, name: group.name_en, title: group.name, sort_no: group.sort_no)
      else
        if (old_category = categories.find_by_parent_id_and_name(nil, group.name_en))
          old_category.update_column(:name, "#{old_category.name}_#{old_category.id}")
        end
        category = categories.create(parent_id: nil, group_code: group.code, name: group.name_en, title: group.name, sort_no: group.sort_no)
      end
      category.copy_from_group(group) unless group.children.empty?
    end
  end

  def sitemap_visible?
    self.sitemap_state == 'visible'
  end

  def unique_sort_key
    '__%032d_%32s' % [self.sort_no.to_i, self.name.to_s]
  end

  private

  def set_defaults
    self.state         = STATE_OPTIONS.first.last         if self.has_attribute?(:state) && self.state.nil?
    self.sitemap_state = SITEMAP_STATE_OPTIONS.first.last if self.has_attribute?(:sitemap_state) && self.sitemap_state.nil?
    self.docs_order    = DOCS_ORDER_OPTIONS.first.last    if self.has_attribute?(:docs_order) && self.docs_order.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end

  def clean_public_path
    FileUtils.rm_r(public_path) if public_path.present? && ::File.exist?(public_path)
  end
end
