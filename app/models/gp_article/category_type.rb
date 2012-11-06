class GpArticle::CategoryType < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'

  validates :concept_id, :presence => true
  validates :content_id, :presence => true

  has_many :categories, :foreign_key => :category_type_id, :class_name => 'GpArticle::Category',
                        :order => :sort_no, :dependent => :destroy

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  default_scope order(:sort_no)
end
