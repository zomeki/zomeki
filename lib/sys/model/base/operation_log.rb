module Sys::Model::Base::OperationLog
  def self.included(base)
    base.has_many :operation_logs, :class_name => 'Sys::OperationLog', :as => :loggable

    base.after_create :log_create
    base.after_update :log_update
    base.before_destroy :log_destroy
  end

  def log_create
    log_operation('create')
  end

  def log_update
    log_operation('update')
  end

  def log_destroy
    log_operation('destroy')
  end

  def log_operation(op)
#    operation_logs.create(user: Core.user, operation: op) if Core.user
  end

  def operated_users
    Sys::User.find(operation_logs.map{|ol| ol.user_id }.uniq)
  end
end
