class CreateSysOperationLogs < ActiveRecord::Migration
  def change
    create_table :sys_operation_logs do |t|
      t.string :loggable_type
      t.references :loggable

      t.references :user
      t.string :operation

      t.timestamps
    end
  end
end
