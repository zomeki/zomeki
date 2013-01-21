class Gnav::MenuItem < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Gnav::Content::MenuItem'
  validates_presence_of :content_id

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_many :category_sets

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true
end
