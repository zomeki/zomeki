class AddFacebookTokenToSnsShareAccounts < ActiveRecord::Migration
  def change
    add_column :sns_share_accounts, :facebook_token_options, :text
    add_column :sns_share_accounts, :facebook_token, :string
  end
end
