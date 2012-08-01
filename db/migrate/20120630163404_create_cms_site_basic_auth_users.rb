class CreateCmsSiteBasicAuthUsers < ActiveRecord::Migration
  def change
    create_table :cms_site_basic_auth_users do |t|
      t.integer :unid
      t.string :state
      t.references :site
      t.string :name
      t.string :password

      t.timestamps
    end
  end
end
