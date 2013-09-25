# encoding: utf-8
class Approval::ApprovalFlow < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Approval::Content::ApprovalFlow'
  validates_presence_of :content_id

  belongs_to :group, :class_name => 'Sys::Group'

  has_many :approvals, :dependent => :destroy
  has_many :approval_requests, :dependent => :destroy

  after_initialize :set_defaults

  validates :title, :presence => true

  private

  def set_defaults
    self.sort_no ||= 10 if self.has_attribute?(:sort_no)
  end
end
