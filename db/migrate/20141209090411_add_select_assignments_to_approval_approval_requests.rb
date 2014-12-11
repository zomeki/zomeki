class AddSelectAssignmentsToApprovalApprovalRequests < ActiveRecord::Migration
  def change
    add_column :approval_approval_requests, :select_assignments, :text
  end
end
