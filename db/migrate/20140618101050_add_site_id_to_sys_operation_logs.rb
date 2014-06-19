class AddSiteIdToSysOperationLogs < ActiveRecord::Migration
  def change
    add_column :sys_operation_logs, :site_id, :integer, :after => :id
    Sys::OperationLog.delete_all
  end
end
