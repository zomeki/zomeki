class GpArticle::CategoryType < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'

  validates :concept_id, :presence => true
  validates :content_id, :presence => true

  has_many :categories, :foreign_key => :category_type_id, :class_name => 'GpArticle::Category',
                        :order => :sort_no, :dependent => :destroy

  validates :name, :presence => true

  default_scope order(:display_order)
end
