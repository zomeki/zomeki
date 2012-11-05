class GpArticle::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Tree
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'

  validates :concept_id, :presence => true
  validates :content_id, :presence => true

  belongs_to :category_type, :foreign_key => :category_type_id, :class_name => 'GpArticle::CategoryType'

  belongs_to :parent, :foreign_key => :parent_id, :class_name => self.name
  has_many :children, :foreign_key => :parent_id, :class_name => self.name,
                      :order => :sort_no, :dependent => :destroy

  belongs_to :layout, :foreign_key => :layout_id, :class_name => 'Cms::Layout'

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  default_scope order(:level_no, :sort_no)
end
