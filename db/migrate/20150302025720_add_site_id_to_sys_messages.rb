class AddSiteIdToSysMessages < ActiveRecord::Migration
  def up
    add_column :sys_messages, :site_id, :integer

    site_id = Cms::Site.first.id
    Sys::Message.find_each do |message|
      message.update_column(:site_id, site_id) unless message.site_id
    end
  end

  def down
    remove_column :sys_messages, :site_id
  end
end
