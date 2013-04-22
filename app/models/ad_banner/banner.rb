# encoding: utf-8
class AdBanner::Banner < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'AdBanner::Content::Banner'
  validates_presence_of :content_id

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  validates :advertiser, :presence => true
end
