class GpCategory::CategoryType < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher

  default_scope order(:sort_no)

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCategory::Content::CategoryType'
  validates_presence_of :content_id

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :layout,  :foreign_key => :layout_id,  :class_name => 'Cms::Layout'

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_many :categories, :foreign_key => :category_type_id, :class_name => 'GpCategory::Category',
                        :order => :sort_no, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  def root_categories
    categories.where(parent_id: nil)
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

  def public_uri=(uri)
    @public_uri = uri
  end

  def public_uri
    return @public_uri if @public_uri
    return nil unless node = content.category_type_node
    @public_uri = "#{node.public_uri}#{name}/"
  end

  def public_full_uri=(uri)
    @public_full_uri = uri
  end

  def public_full_uri
    return @public_full_uri if @public_full_uri
    return nil unless node = content.category_type_node
    @public_full_uri = "#{node.public_full_uri}#{name}/"
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
end
