class Approval::ApprovalRequest < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :requester, :foreign_key => :user_id, :class_name => 'Sys::User'
  validates_presence_of :user_id
  belongs_to :approvable, :polymorphic => true
  validates_presence_of :approvable_type, :approvable_id
  belongs_to :approval_flow
  validates_presence_of :approval_flow_id

  has_many :current_assignments, :class_name => 'Approval::Assignment', :as => :assignable, :dependent => :destroy
  has_many :current_approvers, :through => :current_assignments, :source => :user
  has_many :histories, :foreign_key => :request_id, :class_name => 'Approval::ApprovalRequestHistory', :dependent => :destroy,
           :order => 'updated_at DESC, created_at DESC'

  after_initialize :set_defaults

  def current_approval
    approval_flow.approvals.find_by_index(current_index)
  end

  def current_select_assignments
    select_assignment["approval_#{current_approval.id}"].to_s.split(/ |,/).uniq || []
  end

  def min_index
    0
  end

  def max_index
    approval_flow.approvals.map(&:index).max
  end

  def approve(user)
    return false unless current_approvers.include?(user)

    transaction do
      histories.create(operator: user, reason: 'approve', comment: '')
      if assignment = current_assignments.find_by_user_id(user.id)
        current_assignments.where(or_group_id: assignment.or_group_id).update_all(approved_at: Time.now)
      end
      current_assignments.reload # flush cache
    end

    if current_assignments.all?{|a| a.approved_at }
      if current_index == max_index
        yield('finish') if block_given?
      else
        transaction do
          increment!(:current_index)
          current_assignments.destroy_all
          assginments = current_select_assignments
          current_approval.assignments.each do |assignment|
            next if !assginments.blank? && !assginments.include?(assignment.user_id.to_s)
            current_assignments.create(user_id: assignment.user_id, or_group_id: assignment.or_group_id) 
          end
          reload # flush cache
        end
        yield('progress') if block_given?
      end
    end

    return true
  end

  def passback(approver, comment: '')
    return false unless current_approvers.include?(approver)

    transaction do
      histories.create(operator: approver, reason: 'passback', comment: comment || '')
      reset
    end

    return true
  end

  def pullback(comment: '')
    transaction do
      histories.create(operator: self.requester, reason: 'pullback', comment: comment || '')
      reset
    end

    return true
  end

  def finished?
    current_index == max_index && current_assignments.all?{|a| a.approved_at }
  end

  def reset
    transaction do
      update_column(:current_index, min_index)
      current_assignments.destroy_all
      assginments = current_select_assignments
      current_approval.assignments.each do |assignment|
        next if !assginments.blank? && !assginments.include?(assignment.user_id.to_s)
        current_assignments.create(user_id: assignment.user_id, or_group_id: assignment.or_group_id) 
      end
      reload # flush cache
    end
  end

  def select_assignment=(ev)
    self.select_assignments = YAML.dump(ev) if ev.is_a?(Hash)
    return ev
  end

  def select_assignment
    sa_string = self.select_assignments
    sa = sa_string.kind_of?(String) ? YAML.load(sa_string) : {}.with_indifferent_access
    sa = {}.with_indifferent_access unless sa.kind_of?(Hash)
    sa = sa.with_indifferent_access unless sa.kind_of?(ActiveSupport::HashWithIndifferentAccess)
    if block_given?
      yield sa
      self.select_assignment = sa
    end
    return sa
  end

  def select_assignments_label(approval=nil)
    approval = current_approval if approval.blank?
    ids = select_assignment["approval_#{approval.id}"].to_s.split(' ').uniq
    assignments_by_ogid = approval.assignments.group_by{|g| g.or_group_id }
    users = assignments_by_ogid.select{|_,assignments| ids.index(assignments.map{|a| a.user_id_label}.join(','))}.map{|_,assignments| assignments.map{|a| a.user_label}.join("or")}
    users.join(' and ')
  end

  def select_assignments_ids(approval=nil)
    approval = current_approval if approval.blank?
    ids = select_assignment["approval_#{approval.id}"].to_s.split(/ |,/).uniq
  end

  private

  def set_defaults
    self.current_index = min_index if has_attribute?(:current_index) && current_index.nil?
    if current_approvers.empty?
      current_approval.assignments.each do |assignment|
        current_assignments.build(user_id: assignment.user_id, or_group_id: assignment.or_group_id) 
      end
    end
  end
end
