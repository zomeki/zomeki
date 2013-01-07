# encoding: utf-8
class GpCategory::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Tree
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  default_scope order(:category_type_id, :parent_id, :level_no, :sort_no)

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

  has_and_belongs_to_many :docs, :class_name => 'GpArticle::Doc', :join_table => 'gp_article_docs_gp_category_categories'

  def content
    category_type.content
  end

  def descendants(categories=[])
    categories << self
    children.map {|c| c.descendants(categories) } unless children.empty?
    return categories
  end

  def descendants_for_option(categories=[])
    categories << ["#{'　　' * (level_no - 1)}#{title}", id]
    children.map {|c| c.descendants_for_option(categories) } unless children.empty?
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
end
