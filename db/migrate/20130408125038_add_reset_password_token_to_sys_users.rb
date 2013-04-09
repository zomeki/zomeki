class AddResetPasswordTokenToSysUsers < ActiveRecord::Migration
  def change
    add_column :sys_users, :reset_password_token, :string
    add_column :sys_users, :reset_password_token_expires_at, :datetime
  end
end
