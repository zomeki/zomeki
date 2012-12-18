class GpCategory::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Tree
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  default_scope order(:category_type_id, :level_no, :sort_no)

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

  validates :name, :presence => true, :uniqueness => {:scope => [:category_type_id, :level_no]}
  validates :title, :presence => true

  has_and_belongs_to_many :docs, :class_name => 'GpArticle::Doc', :join_table => 'gp_article_docs_gp_category_categories'

  def content
    category_type.content
  end

#  def descendants(categories=[])
#    categories << ["#{'-' * level_no} #{parent.try(:title)}:#{title}", id]
#
#    unless children.empty?
#      children.map {|c| c.descendants(categories) }
#    end
#
#    return categories
#  end
end
