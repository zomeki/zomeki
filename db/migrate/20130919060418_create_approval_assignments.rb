class CreateApprovalAssignments < ActiveRecord::Migration
  def change
    create_table :approval_assignments do |t|
      t.belongs_to :approval
      t.belongs_to :user

      t.timestamps
    end
    add_index :approval_assignments, :approval_id
    add_index :approval_assignments, :user_id
  end
end
