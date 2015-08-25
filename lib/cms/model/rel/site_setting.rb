module Cms::Model::Rel::SiteSetting
  attr_accessor :in_setting_site_admin_protocol

  SITE_SETTINGS = [:admin_protocol]

  def self.included(mod)
  end

  def setting_site_admin_protocol
    setting = Cms::SiteSetting::AdminProtocol.where(:site_id => id, :name => 'admin_protocol').first
    setting ? setting.value : nil;
  end

  def load_site_settings
    @in_setting_site_admin_protocol   = setting_site_admin_protocol
  end

  def save_site_settings(options={})
    return true unless options
    return true unless options[:site_id]

    _site_id = options[:site_id]

    SITE_SETTINGS.each do |name|
      _value = eval("in_setting_site_#{name.to_s}")
      if setting = Cms::SiteSetting.where(:site_id => _site_id, :name => name.to_s).first
        setting.value = _value
        setting.save
      else
        Cms::SiteSetting.create(:site_id => _site_id, :name => name.to_s, :value => _value)
      end
    end
  end

end
