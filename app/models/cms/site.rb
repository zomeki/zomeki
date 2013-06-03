# encoding: utf-8
class Cms::Site < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager
  include Cms::Model::Rel::DataFile
  include PortalGroup::Model::Rel::Site::Category
  include PortalGroup::Model::Rel::Site::Business
  include PortalGroup::Model::Rel::Site::Attribute
  include PortalGroup::Model::Rel::Site::Area
  
  belongs_to :status, :foreign_key => :state,
    :class_name => 'Sys::Base::Status'
  belongs_to :portal_group_status, :foreign_key => :portal_group_state,
    :class_name => 'Sys::Base::Status'
  belongs_to :portal_group, :foreign_key => :portal_group_id,
    :class_name => 'PortalGroup::Content::Group'
  has_many   :concepts, :foreign_key => :site_id, :order => 'name, id',
    :class_name => 'Cms::Concept', :dependent => :destroy
  has_many   :contents, :foreign_key => :site_id, :order => 'name, id',
    :class_name => 'Cms::Content'
  has_many   :settings, :foreign_key => :site_id, :order => 'name, sort_no',
    :class_name => 'Cms::SiteSetting'
  has_many   :basic_auth_users, :foreign_key => :site_id, :order => 'name',
    :class_name => 'Cms::SiteBasicAuthUser'
  has_many :site_belongings, :dependent => :destroy, :class_name => 'Cms::SiteBelonging'
  has_many :groups, :through => :site_belongings, :class_name => 'Sys::Group'
  
  validates_presence_of :state, :name, :full_uri
  validates_uniqueness_of :full_uri
  validates_uniqueness_of :mobile_full_uri,
    :if => %Q(!mobile_full_uri.blank?)
  validate :validate_attributes
  
  ## site image
  attr_accessor :site_image, :del_site_image
  after_save { save_cms_data_file(:site_image, :site_id => id) }
  after_destroy { destroy_cms_data_file(:site_image) }

  before_destroy :block_main_deletion

  def states
    [['公開','public']]
  end
  
  def portal_group_states
    [['表示','visible'],['非表示','hidden']]
  end
  
  def public_path
    dir = format('%08d', id).gsub(/((..)(..)(..)(..))/, '\\2/\\3/\\4/\\5/\\1')
    "#{Rails.root}/sites/#{dir}/public"
  end
  
  def config_path
    dir = format('%08d', id).gsub(/((..)(..)(..)(..))/, '\\2/\\3/\\4/\\5/\\1')
    "#{Rails.root}/sites/#{dir}/config"
  end
  
  def uri
    return '/' unless full_uri.match(/^[a-z]+:\/\/[^\/]+\//)
    full_uri.sub(/^[a-z]+:\/\/[^\/]+\//, '/')
  end

  def domain
    return '' if full_uri.blank?
    URI.parse(full_uri).host
  end

  def mobile_domain
    return '' if mobile_full_uri.blank?
    URI.parse(mobile_full_uri).host
  end

  def publish_uri
    "#{Core.full_uri}_publish/#{format('%08d', id)}/"
  end
  
  def has_mobile?
    !mobile_full_uri.blank?
  end
  
  def root_node
    Cms::Node.find_by_id(node_id)
  end
  
  def related_sites(options = {})
    sites = []
    related_site.to_s.split(/(\r\n|\n)/).each do |line|
      sites << line if line.strip != ''
    end
    if options[:include_self]
      sites << "#{full_uri}" if !full_uri.blank?
      sites << "#{mobile_full_uri}" if !mobile_full_uri.blank?
    end
    sites
  end
  
  def site_image_uri
    cms_data_file_uri(:site_image, :site_id => id)
  end
  
  def self.find_by_script_uri(script_uri)
    base = script_uri.gsub(/^([a-z]+:\/\/[^\/]+\/).*/, '\1')
    item = Cms::Site.new.public
    cond = Condition.new do |c|
      c.or :full_uri, 'LIKE', "#{base}%"
      c.or :mobile_full_uri, 'LIKE', "#{base}%"
    end
    item.and cond
    return item.find(:first, :order => :id)
  end
  
  def self.make_virtual_hosts_config
    conf = '';
    find(:all, :order => :id).each do |site|
      next unless ::File.exist?(site.public_path)
      next unless ::File.exist?(site.config_path + "/rewrite.conf")

      domain = site.domain
      next unless domain.to_s =~ /^[1-9a-z\.\-\_]+$/i

      conf.concat(<<-EOT)
<VirtualHost *:80>
    AddType text/x-component .htc
    DocumentRoot #{site.public_path}
    Alias /_common/ "#{Rails.root}/public/_common/"
    ServerName #{domain}
      EOT

      if (md = site.mobile_domain).to_s =~ /^[1-9a-z\.\-\_]+$/i
        conf.concat(<<-EOT)
    ServerAlias #{md}
    SetEnvIf Host #{Regexp.quote(md)} MOBILE_SITE
        EOT
      end

      conf.concat(<<-EOT)
    Include #{Rails.root}/config/rewrite/base.conf
    Include #{site.config_path}/rewrite.conf
</VirtualHost>

      EOT
    end
    conf
  end
  
  def self.put_virtual_hosts_config
    conf = make_virtual_hosts_config
    Util::File.put("#{Rails.root}/config/virtual-hosts/sites.conf", :data => conf)
  end
  
  def basic_auth_enabled?
    pw_file = "#{::File.dirname(public_path)}/.htpasswd"
    return ::File.exists?(pw_file)
  end
  
  def enable_basic_auth
    ac_file = "#{::File.dirname(public_path)}/.htaccess"
    pw_file = "#{::File.dirname(public_path)}/.htpasswd"
    
    conf  = %Q(<FilesMatch "^(?!#{ZomekiCMS::ADMIN_URL_PREFIX})">\n)
    conf += %Q(    AuthUserFile #{pw_file}\n)
    conf += %Q(    AuthGroupFile /dev/null\n)
    conf += %Q(    AuthName "Please enter your ID and password"\n)
    conf += %Q(    AuthType Basic\n)
    conf += %Q(    require valid-user\n)
    conf += %Q(    allow from all\n)
    conf += %Q(</FilesMatch>\n)
    #conf += %Q(<FilesMatch "^_dynamic">\n)
    #conf += %Q(    Order allow,deny\n)
    #conf += %Q(    Allow from All\n)
    #conf += %Q(    Satisfy Any\n)
    #conf += %Q(</FilesMatch>\n)
    Util::File.put(ac_file, :data => conf)
    
    salt = Zomeki.config.application['sys.crypt_pass']
    conf = ""
    basic_auth_users.each do |user|
      conf += %Q(#{user.name}:#{user.password.crypt(salt)}\n)
    end
    Util::File.put(pw_file, :data => conf)
    
    return true
  end
  
  def disable_basic_auth
    ac_file = "#{::File.dirname(public_path)}/.htaccess"
    pw_file = "#{::File.dirname(public_path)}/.htpasswd"
    FileUtils.rm(ac_file)
    FileUtils.rm(pw_file)
    
    return true
  end

  def main?
    self.id == 1
  end

  def groups_for_option
    groups.where(level_no: 2).map{|g| g.descendants_for_option }.flatten(1)
  end

protected
  def validate_attributes
    if !full_uri.blank? && full_uri !~ /^[a-z]+:\/\/[^\/]+\//
      self.full_uri += '/'
    end
    return true
  end

  def block_main_deletion
    raise "Main site can't be deleted." if self.main?
  end
end
