class CreateSnsShareAccounts < ActiveRecord::Migration
  def change
    create_table :sns_share_accounts do |t|
      t.belongs_to :content
      t.string :provider
      t.string :uid
      t.string :info_nickname
      t.string :info_name
      t.string :info_image
      t.string :info_url
      t.string :credential_token
      t.string :credential_expires_at
      t.string :credential_secret
      t.text   :facebook_page_options
      t.string :facebook_page

      t.timestamps
    end
    add_index :sns_share_accounts, :content_id
  end
end
