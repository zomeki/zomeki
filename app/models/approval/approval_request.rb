class Approval::ApprovalRequest < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :approvable, :polymorphic => true
  belongs_to :approval_flow

  after_initialize :set_defaults

  private

  def set_defaults
    self.current_index ||= 0 if self.has_attribute?(:current_index)
  end
end
