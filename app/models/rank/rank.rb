class Rank::Rank < ActiveRecord::Base
  include Sys::Model::Base

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Rank::Content::Rank'
  validates_presence_of :content_id

end
