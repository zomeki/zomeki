class AddSmartPhonePublicationToCmsSites < ActiveRecord::Migration
  def change
    add_column :cms_sites, :smart_phone_publication, :string
  end
end
