class AddOrGroupIdToApprovalAssignments < ActiveRecord::Migration
  def change
    add_column :approval_assignments, :or_group_id, :integer
    Approval::Approval.all.each do |approval|
      approval.assignments.each_with_index do |assignment, i|
        assignment.update_column(:or_group_id, i)
      end
    end
    Approval::ApprovalRequest.all.each do |request|
      request.current_assignments.each_with_index do |assignment, i|
        assignment.update_column(:or_group_id, i)
      end
    end
  end
end
