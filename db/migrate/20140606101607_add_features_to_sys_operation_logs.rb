class AddFeaturesToSysOperationLogs < ActiveRecord::Migration
  def change
    add_column :sys_operation_logs, :user_name, :string
    add_column :sys_operation_logs, :ipaddr, :string
    add_column :sys_operation_logs, :uri, :string
    add_column :sys_operation_logs, :action, :string
    add_column :sys_operation_logs, :item_model, :string
    add_column :sys_operation_logs, :item_id, :integer
    add_column :sys_operation_logs, :item_unid, :integer
    add_column :sys_operation_logs, :item_name, :string
  end
end
