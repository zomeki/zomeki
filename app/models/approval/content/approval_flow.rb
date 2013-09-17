# encoding: utf-8
class Approval::Content::ApprovalFlow < Cms::Content
  default_scope where(model: 'Approval::ApprovalFlow')

  has_many :approval_flows, :foreign_key => :content_id, :class_name => 'Approval::ApprovalFlow', :dependent => :destroy
end
