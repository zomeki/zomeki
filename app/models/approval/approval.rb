class Approval::Approval < ActiveRecord::Base
  include Sys::Model::Base

  default_scope order("#{self.table_name}.approval_flow_id, #{self.table_name}.index")

  belongs_to :approval_flow

  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments

  validates :index, :presence => true, :uniqueness => {:scope => [:approval_flow_id]}

  after_initialize :set_defaults

  private

  def set_defaults
    self.index ||= approval_flow.approvals.count + 1 if self.has_attribute?(:index)
  end
end
