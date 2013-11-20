class CreateApprovalApprovalRequestHistories < ActiveRecord::Migration
  def change
    create_table :approval_approval_request_histories do |t|
      t.belongs_to :request
      t.belongs_to :user
      t.string :reason
      t.text :comment

      t.timestamps
    end
    add_index :approval_approval_request_histories, :request_id
    add_index :approval_approval_request_histories, :user_id
  end
end
