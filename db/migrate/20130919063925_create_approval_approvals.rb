class CreateApprovalApprovals < ActiveRecord::Migration
  def change
    create_table :approval_approvals do |t|
      t.belongs_to :approval_flow
      t.integer    :index

      t.timestamps
    end
  end
end
