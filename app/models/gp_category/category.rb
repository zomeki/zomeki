# encoding: utf-8
class GpCategory::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Tree
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  default_scope order(:category_type_id, :level_no, :parent_id, :sort_no)

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :layout,  :foreign_key => :layout_id,  :class_name => 'Cms::Layout'

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  belongs_to :category_type, :foreign_key => :category_type_id, :class_name => 'GpCategory::CategoryType'
  validates_presence_of :category_type_id

  belongs_to :parent, :foreign_key => :parent_id, :class_name => self.name
  has_many :children, :foreign_key => :parent_id, :class_name => self.name,
                      :order => [:level_no, :sort_no], :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:scope => [:category_type_id, :parent_id]}
  validates :title, :presence => true

  has_and_belongs_to_many :docs, :class_name => 'GpArticle::Doc', :join_table => 'gp_article_docs_gp_category_categories', :order => 'published_at, updated_at'

  belongs_to :group, :foreign_key => :group_code, :class_name => 'Sys::Group'

  after_initialize :set_defaults

  before_validation :set_attributes_from_parent

  scope :public, where(state: 'public')

  def content
    category_type.content
  end

  def descendants(categories=[])
    categories << self
    children.each {|c| c.descendants(categories) } unless children.empty?
    return categories
  end

  def public_descendants(categories=[])
    return categories unless self.public?
    categories << self
    children.each {|c| c.public_descendants(categories) } unless children.empty?
    return categories
  end

  def descendants_for_option(categories=[])
    categories << ["#{'　　' * (level_no - 1)}#{title}", id]
    children.each {|c| c.descendants_for_option(categories) } unless children.empty?
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

  def public_docs
    docs.mobile(::Page.mobile?).public
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

  private

  def set_defaults
    self.state   ||= 'public' if self.has_attribute?(:state)
    self.sort_no ||= 0        if self.has_attribute?(:sort_no)
  end

  def set_attributes_from_parent
    if parent
      self.category_type = parent.category_type
      self.level_no = parent.level_no + 1
    else
      self.level_no = 1
    end
  end
end
