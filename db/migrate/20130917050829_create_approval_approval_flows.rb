class CreateApprovalApprovalFlows < ActiveRecord::Migration
  def change
    create_table :approval_approval_flows do |t|
      t.integer    :unid
      t.belongs_to :content

      t.string     :title
      t.belongs_to :group
      t.integer    :sort_no

      t.timestamps
    end
  end
end
