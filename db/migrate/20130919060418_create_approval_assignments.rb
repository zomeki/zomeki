class CreateApprovalAssignments < ActiveRecord::Migration
  def change
    create_table :approval_assignments do |t|
      t.belongs_to :assignable, polymorphic: true
      t.belongs_to :user
      t.string     :state

      t.timestamps
    end
    add_index :approval_assignments, [:assignable_type, :assignable_id]
    add_index :approval_assignments, :user_id
  end
end
