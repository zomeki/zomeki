# encoding: utf-8
class Core
  ## Core attributes.
  cattr_reader   :now
  cattr_reader   :config
  cattr_reader   :title
  cattr_reader   :env
  cattr_reader   :params
  cattr_reader   :mode
  cattr_reader   :site
  cattr_reader   :script_uri
  cattr_reader   :request_uri
  cattr_reader   :internal_uri
  cattr_accessor :ldap
  cattr_accessor :user
  cattr_accessor :user_group
  cattr_accessor :dispatched
  cattr_accessor :concept
  cattr_accessor :messages
  cattr_accessor :publish
  
  ## Initializes.
  def self.initialize(env = {})
    @@now          = Time.now.to_s(:db)
    @@config       = Util::Config.load(:core)
    @@title        = @@config['title'] || 'ZOMEKI'
    @@env          = env
    @@params       = parse_query_string(env)
    @@mode         = nil
    @@site         = nil
    @@script_uri   = env['SCRIPT_URI'] || "http://#{env['HTTP_HOST']}#{env['PATH_INFO']}"
    @@request_uri  = nil
    @@internal_uri = nil
    @@ldap         = nil
    @@user         = nil
    @@user_group   = nil
    @@dispatched   = nil
    @@concept      = nil
    @@messages     = []
    @@publish      = nil # for mobile
    
    #require 'page'
    Page.initialize
  end
  
  ## Now.
  def self.now
    return @@now if @@now
    return @@now = Time.now.to_s(:db)
  end
  
  ## Absolute path.
  def self.uri
    return '/' unless @@config['uri'].match(/^[a-z]+:\/\/[^\/]+\//)
    @@config['uri'].sub(/^[a-z]+:\/\/[^\/]+\//, '/')
  end
  
  ## Full URI.
  def self.full_uri
    @@config['uri']
  end
  
  ## Proxy.
  def self.proxy
    @@config['proxy']
  end
  
  ## Parses query string.
  def self.parse_query_string(env)
    env['QUERY_STRING'] ? CGI.parse(env['QUERY_STRING']) : nil
  end
  
  ## Sets the mode.
  def self.set_mode(mode)
    old = @@mode
    @@mode = mode
    return old
  end
  
  ## LDAP.
  def self.ldap
    return @@ldap if @@ldap
    @@ldap = Sys::Lib::Ldap.new()
  end
  
  ## Controller was dispatched?
  def self.dispatched?
    @@dispatched
  end
  
  ## Controller was dispatched.
  def self.dispatched
    @@dispatched = true
  end
  
  ## Recognizes the path for dispatch.
  def self.recognize_path(path)
    if Core.env['REQUEST_URI']
      path += '/' if path !~ /\/$/ && Core.env['REQUEST_URI'] =~ /\/$/
    end
    
    Page.error    = false
    Page.uri      = path
    @@request_uri = path
    
    self.recognize_mode
    self.recognize_site
    
    @@internal_uri = '/404.html' unless @@internal_uri
  end
  
  def self.search_node(path)
    return nil unless Page.site
    
    if path =~ /\.html\.r$/
      Page.ruby = true
      path = path.gsub(/\.r$/, '')
    end
    if path =~ /\.p[0-9]+\.html$/
      path = path.gsub(/\.p[0-9]+\.html$/, '.html')
    end
    if path =~ /\/$/
      path += 'index.html'
    end
    
    node     = nil
    rest     = ''
    paths    = path.gsub(/\/+/, '/').split('/')
    paths[0] = '/'
    
    paths.size.times do |i|
      if i == 0
        current = Cms::Node.find(Page.site.node_id)
      else
        n = Cms::Node.new
        n.and :site_id  , Page.site.id
        n.and :parent_id, node.id
        n.and :name     , paths[i]
        n.public if @@mode != 'preview'
        current = n.find(:first, :order => "id ASC") # at unique node name
      end
      break unless current
      
      node = current
      rest = paths.slice(i + 1, paths.size).join('/')
    end
    return nil unless node
    
    Page.current_node = node
    @@internal_uri  = "/_public/#{node.model.underscore.pluralize.gsub(/^(.*?\/)/, "\\1node_")}"
    @@internal_uri += "/#{rest}" if !rest.blank?
    @@internal_uri
  end
  
  def self.concept(key = nil)
    return nil unless @@concept
    key.nil? ? @@concept : @@concept.send(key)
  end
  
  def self.set_concept(session, concept_id = nil)
    if concept_id
      @@concept = Cms::Concept.find_by_id(concept_id)
      @@concept = Cms::Concept.new.readable_children[0] unless @@concept
      session[:cms_concept] = (@@concept ? @@concept.id : nil)
    else
      concept_id = session[:cms_concept]
      @@concept = Cms::Concept.find_by_id(concept_id) || Cms::Concept.new.readable_children[0]
    end
  end
  
private
  def self.recognize_mode
    if @@request_uri =~ %r!^/_[a-z]+(/|$)!
      @@mode = @@request_uri.scan(%r!(?<=^/_)[a-z]+!).first
    elsif @@request_uri =~ %r!^/assets/!
      @@mode = 'asset'
    else
      @@mode = 'public'
    end
  end
  
  def self.recognize_site
    case @@mode
    when 'system'
      @@site          = self.get_site_by_cookie || find_site_by_script_uri(@@script_uri) || Cms::Site.order(:id).first
      Page.site       = @@site
      @@internal_uri  = @@request_uri
    when 'preview'
      site_id         = @@request_uri.gsub(/^\/_[a-z]+\/([0-9]+).*/, '\1').to_i
      site_mobile     = @@request_uri =~ /^\/_[a-z]+\/([0-9]+)m/
      @@site          = Cms::Site.find(site_id)
      Page.site       = @@site
      Page.mobile     = site_mobile
      @@internal_uri  = @@request_uri
      @@internal_uri += "index.html" if @@internal_uri =~ /\/$/
    when 'public'
      @@site          = find_site_by_script_uri(@@script_uri)
      Page.site       = @@site
      @@internal_uri  = search_node @@request_uri
    when 'layouts'
      @@site          = find_site_by_script_uri(@@script_uri)
      Page.site       = @@site
      @@internal_uri  = '/_public/cms/layouts' + @@request_uri.gsub(/.*?_layouts/, '')
    when 'script'
      if @@env.key?('SERVER_PROTOCOL') == false
        @@site          = nil
        Page.site       = @@site
        @@internal_uri  = @@request_uri
      end
    else
      @@site          = find_site_by_script_uri(@@script_uri)
      Page.site       = @@site
      @@internal_uri  = @@request_uri
    end
  end
  
  def self.get_site_by_cookie
    return Cms::Site.find_by_id(self.get_cookie('cms_site'))
  end
  
  def self.get_cookie(name)
    cookies = CGI::Cookie.parse(Core.env['HTTP_COOKIE'])
    return cookies[name].value.first if cookies.has_key?(name)
    return nil
  end

  def self.find_site_by_script_uri(uri)
    Cms::Site.find_by_script_uri(uri) || Cms::Site.find_by_script_uri(uri.sub(/^https:/, 'http:'))
  end
end
