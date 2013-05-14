# encoding: utf-8
class AdBanner::Group < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  default_scope order(:sort_no)

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'AdBanner::Content::Banner'
  validates_presence_of :content_id

  # Proper
  has_many :banners, :foreign_key => :group_id, :class_name => 'AdBanner::Banner'

  validates :name, :presence => true
  validates :title, :presence => true

  after_initialize :set_defaults
  before_destroy :uncategorize

  private

  def set_defaults
    self.sort_no ||= 10 if self.has_attribute?(:sort_no)
  end

  def uncategorize
    banners.clear
  end
end
