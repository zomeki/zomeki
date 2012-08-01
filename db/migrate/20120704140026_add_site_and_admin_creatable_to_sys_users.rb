class AddSiteAndAdminCreatableToSysUsers < ActiveRecord::Migration
  def change
    add_column :sys_users, :admin_creatable, :boolean, :default => false
    add_column :sys_users, :site_creatable, :boolean, :default => false
  end
end
