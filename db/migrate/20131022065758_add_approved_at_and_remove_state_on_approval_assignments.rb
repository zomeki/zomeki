class AddApprovedAtAndRemoveStateOnApprovalAssignments < ActiveRecord::Migration
  def up
    remove_column :approval_assignments, :state
    add_column :approval_assignments, :approved_at, :datetime
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
