class Approval::Approval < ActiveRecord::Base
  include Sys::Model::Base

  TYPE_OPTIONS = [['固定', 'fix'], ['選択', 'select']]

  default_scope order("#{self.table_name}.approval_flow_id, #{self.table_name}.index")

  belongs_to :approval_flow
  validates_presence_of :approval_flow_id

  has_many :assignments, :as => :assignable, :dependent => :destroy
  has_many :approvers, :through => :assignments, :source => :user

  validates :index, :presence => true, :uniqueness => {:scope => [:approval_flow_id]}

  after_initialize :set_defaults

  def select_approve?
    approval_type == 'select'
  end

  def approvers_label
    a = assignments.group_by{|assignments| assignments.or_group_id }.map{|og, assignments_by_og|
      assignments_by_og.map{|a| a.user_label}.join(" or ")
    }
    if self.select_approve?
      return (a.size > 1) ? "[#{a.map{|aa| aa =~ / or / ? "（#{aa}）" : aa  }.join(' or ')}]" : a
    else
      return a.join(" and ")
    end
  end

  def approval_type_title
    ATYPE_OPTIONS.detect{|o| o.last == approval_type }.try(:first)
  end

  private

  def set_defaults
    self.approval_type ||= TYPE_OPTIONS.first.last if self.has_attribute?(:approval_type)
    self.index ||= approval_flow.approvals.count if self.has_attribute?(:index)
  end
end
