class AddNicknameAndUrlToCmsOAuthUsers < ActiveRecord::Migration
  def change
    add_column :cms_o_auth_users, :nickname, :string
    add_column :cms_o_auth_users, :url, :string
  end
end
