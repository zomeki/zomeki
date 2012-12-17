class GpCategory::CategoryType < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  default_scope order(:sort_no)

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCategory::Content::CategoryType'
  validates_presence_of :concept_id, :content_id

  belongs_to :layout, :foreign_key => :layout_id, :class_name => 'Cms::Layout'
  belongs_to :status, :foreign_key => :state,     :class_name => 'Sys::Base::Status'

  has_many :categories, :foreign_key => :category_type_id, :class_name => 'GpCategory::Category',
                        :order => :sort_no, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  def root_categories
    categories.where(parent_id: nil)
  end
end
