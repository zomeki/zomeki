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
                        :order => [:category_type_id, :level_no, :parent_id, :sort_no], :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  after_initialize :set_defaults

  scope :public, where(state: 'public')

  def public_categories
    categories.public
  end

  def root_categories
    categories.where(parent_id: nil)
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

  def public_uri=(uri)
    @public_uri = uri
  end

  def public_uri
    return @public_uri if @public_uri
    return '' unless node = content.category_type_node
    @public_uri = "#{node.public_uri}#{name}/"
  end

  def public_full_uri=(uri)
    @public_full_uri = uri
  end

  def public_full_uri
    return @public_full_uri if @public_full_uri
    return '' unless node = content.category_type_node
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

  private

  def set_defaults
    self.state   ||= 'public' if self.has_attribute?(:state)
    self.sort_no ||= 10       if self.has_attribute?(:sort_no)
  end
end
