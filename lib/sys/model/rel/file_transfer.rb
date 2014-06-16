module Sys::Model::Rel::FileTransfer
  attr_accessor :in_setting_transfer_dest_user, :in_setting_transfer_dest_host,
    :in_setting_transfer_dest_dir, :in_setting_transfer_dest_domain

  FILE_TRANSFER_SETTINGS = [:transfer_dest_user, :transfer_dest_host, :transfer_dest_dir, :transfer_dest_domain]

  def self.included(mod)
  end

  def setting_transfer_dest_user
    setting = Cms::SiteSetting::FileTransfer.where(:site_id => id, :name => 'transfer_dest_user').first
    setting ? setting.value : nil;
  end

  def setting_transfer_dest_host
    setting = Cms::SiteSetting::FileTransfer.where(:site_id => id, :name => 'transfer_dest_host').first
    setting ? setting.value : nil;
  end

  def setting_transfer_dest_dir
    setting = Cms::SiteSetting::FileTransfer.where(:site_id => id, :name => 'transfer_dest_dir').first
    setting ? setting.value : nil;
  end

   def setting_transfer_dest_domain
    setting = Cms::SiteSetting::FileTransfer.where(:site_id => id, :name => 'transfer_dest_domain').first
    setting ? setting.value : nil;
  end

  def load_file_transfer
    @in_setting_transfer_dest_user   = setting_transfer_dest_user
    @in_setting_transfer_dest_host   = setting_transfer_dest_host
    @in_setting_transfer_dest_dir    = setting_transfer_dest_dir
    @in_setting_transfer_dest_domain = setting_transfer_dest_domain
  end

  def save_file_transfer(options={})
    return true unless options
    return true unless options[:site_id]

    _site_id = options[:site_id]

    FILE_TRANSFER_SETTINGS.each do |name|
      _value = eval("in_setting_#{name.to_s}")
      if setting = Cms::SiteSetting::FileTransfer.where(:site_id => _site_id, :name => name.to_s).first
        setting.value = _value
        setting.save
      else
        Cms::SiteSetting::FileTransfer.create(:site_id => _site_id, :name => name.to_s, :value => _value)
      end
    end
  end

end
