class Survey::Form < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Survey::Content::Form'
  validates_presence_of :content_id

  validates :title, :presence => true
end
