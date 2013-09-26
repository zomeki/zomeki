class Approval::ApprovalRequest < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :approvable, :polymorphic => true
  belongs_to :approval_flow

  has_many :assignments, :as => :assignable, :dependent => :destroy
  has_many :current_users, :through => :assignments, :source => :user

  after_initialize :set_defaults

  def current_approval
    approval_flow.approvals.find_by_index(current_index)
  end

  private

  def set_defaults
    self.current_index ||= 0 if self.has_attribute?(:current_index)
    self.current_users = current_approval.users if current_users.empty?
  end
end
