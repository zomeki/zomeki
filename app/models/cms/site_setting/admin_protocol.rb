# encoding: utf-8
class Cms::SiteSetting::AdminProtocol < Cms::SiteSetting

  ADMIN_PROTOCOLS = [['http', 'http'], ['https', 'https']]

  validates_uniqueness_of :value, :scope => :name

  def self.core_domain(site, default_uri=nil, options={})
    mode = Zomeki.config.application['sys.core_domain']
    d = (mode == 'core') ? Core.full_uri : default_uri;
    return d if options[:freeze_protocol] && options[:freeze_protocol] == true

    _admin_protocol = site.setting_site_admin_protocol
    if _admin_protocol == 'https'
      d.gsub(/^http[^s]/, "https:")
    else
      d.gsub(/^https/, "http")
    end
  end

end
