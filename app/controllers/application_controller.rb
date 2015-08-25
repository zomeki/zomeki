# encoding: utf-8
class ApplicationController < ActionController::Base
  include Cms::Controller::Public
  helper  FormHelper
  helper  LinkHelper
  protect_from_forgery # :secret => '1f0d667235154ecf25eaf90055d99e99'
  before_filter :initialize_application
#  rescue_from Exception, :with => :rescue_exception
  
  def initialize_application
    if Core.publish
      Page.mobile = false
      Page.smart_phone = false
    else
      Page.mobile = true if request.mobile?
      Page.smart_phone = true if request.smart_phone?
      request_as_mobile if Page.mobile? && !request.mobile?
    end
    return false if Core.dispatched?
    return Core.dispatched
  end
  
  def query(params = nil)
    Util::Http::QueryString.get_query(params)
  end
  
  def send_mail(fr_addr, to_addr, subject, body)
    return false if fr_addr.blank? || to_addr.blank?
    CommonMailer.plain(from: fr_addr, to: to_addr, subject: subject, body: body).deliver
  end
  
  def send_download
    #
  end

private
  def rescue_action(error)
    case error
    when ActionController::InvalidAuthenticityToken
      http_error(422, "Invalid Authenticity Token")
    else
      super
    end
  end
  
  ## Production && local
  def rescue_action_in_public(exception)
    http_error(500, nil)
  end
  
  def http_error(status, message = nil)
    self.response_body = nil
    Page.error = status
    
    if status == 404
      message ||= "ページが見つかりません。"
    end
    
    name    = Rack::Utils::HTTP_STATUS_CODES[status]
    name    = " #{name}" if name
    message = " ( #{message} )" if message
    message = "#{status}#{name}#{message}"
    
    mode_regexp = Regexp.new("^(#{ZomekiCMS::ADMIN_URL_PREFIX.sub(/^_/, '')}|script)$")
    if Core.mode =~ mode_regexp && status != 404
      error_log("#{status} #{request.env['REQUEST_URI']}") if status != 404
      render :status => status, :text => "<p>#{message}</p>", :layout => "admin/cms/error"
      return
#      return respond_to do |format|
#        format.html { render :status => status, :text => "<p>#{message}</p>", :layout => "admin/cms/error" }
#        format.xml  { render :status => status, :xml => "<errors><error>#{message}</error></errors>" }
#      end
    end
    
    ## Render
    html = nil
    if Page.mobile
      file_status = "#{status}_mobile.html"
      file_500 = "500_mobile.html"
    else
      file_status = "#{status}.html"
      file_500 = "500.html"
    end
    if Page.site && FileTest.exist?("#{Page.site.public_path}/#{file_status}")
      html = ::File.new("#{Page.site.public_path}/#{file_status}").read
    elsif Core.site && FileTest.exist?("#{Core.site.public_path}/#{file_status}")
      html = ::File.new("#{Core.site.public_path}/#{file_status}").read
    elsif FileTest.exist?("#{Rails.public_path}/#{file_status}")
      html = ::File.new("#{Rails.public_path}/#{file_status}").read
    elsif FileTest.exist?("#{Rails.public_path}/#{file_500}")
      html = ::File.new("#{Rails.public_path}/#{file_500}").read
    else
      html = "<html>\n<head></head>\n<body>\n<p>#{message}</p>\n</body>\n</html>\n"
    end

    if Core.mode == 'ssl'
      form_nodes = Cms::Node.where(model: 'Survey::Form', site_id: Page.site.id)
      form_nodes = form_nodes.select {|f| Survey::Content::Form.find_by_id(f.content.id).use_common_ssl? }
      form_nodes = form_nodes.map{|f| f.public_uri }

      str = Nokogiri::HTML(html.force_encoding('UTF-8'), nil, 'utf-8')

      ssl_uri = Page.site.full_ssl_uri.sub(/\/\z/, '')
      unless form_nodes.blank?
        str.css(*form_nodes.map{|n| %Q!a[href^="#{n}"]! }).each do |a_tag|
          a_tag.set_attribute('href', "#{ssl_uri}#{a_tag.attribute('href')}")
        end
        str.css(*form_nodes.map{|n| %Q!form[action^="#{n}"]! }).each do |form_tag|
          form_tag.set_attribute('action', "#{ssl_uri}#{form_tag.attribute('action')}")
        end
      end

      site_full_uri = Page.site.full_uri.sub(/\/\z/, '')
      str.css('a[href^="/"]').each do |a_tag|
        href = a_tag.attribute('href').to_s
        a_tag.set_attribute('href', "#{site_full_uri}#{href}") unless href =~ Regexp.new("\\A#{form_nodes.join('|')}")
      end
      str.css('area[href^="/"]').each do |a_tag|
        href = a_tag.attribute('href').to_s
        a_tag.set_attribute('href', "#{site_full_uri}#{href}") unless href =~ Regexp.new("\\A#{form_nodes.join('|')}")
      end
      str.css('link[href^="/"]').each do |link_tag|
        href = link_tag.attribute('href').to_s
        link_tag.set_attribute('href', "#{ssl_uri}#{href}") if href =~ /^\/_(layouts|themes|file|emfiles)/
      end
      str.css('img[src^="/"]').each do |src_tag|
        src = src_tag.attribute('src').to_s
        src_tag.set_attribute('src', "#{ssl_uri}#{src}") if src =~ /^\/_(layouts|themes|file|emfiles)/
      end
      str.css('script[src^="/"]').each do |src_tag|
        src = src_tag.attribute('src').to_s
        src_tag.set_attribute('src', "#{ssl_uri}#{src}") if src =~ /^\/_(layouts|themes|file|emfiles)/
      end
      html = str.to_s
    end

    render :status => status, :inline => html
#    return respond_to do |format|
#      format.html { render :status => status, :inline => html }
#      format.xml  { render :status => status, :xml => "<errors><error>#{message}</error></errors>" }
#    end
  end
  
#  def rescue_exception(exception)
#    log  = exception.to_s
#    log += "\n" + exception.backtrace.join("\n") if Rails.env.to_s == 'production'
#    error_log(log)
#    
#    if Core.mode =~ /^(admin|script)$/
#      html  = %Q(<div style="padding: 0px 20px 10px; color: #e00; font-weight: bold; line-height: 1.8;">)
#      html += %Q(エラーが発生しました。<br />#{exception} &lt;#{exception.class}&gt;)
#      html += %Q(</div>)
#      if Rails.env.to_s != 'production'
#        html += %Q(<div style="padding: 15px 20px; border-top: 1px solid #ccc; color: #800; line-height: 1.4;">)
#        html += exception.backtrace.join("<br />")
#        html += %Q(</div>)
#      end
#      render :inline => html, :layout => "admin/cms/error", :status => 500
#    else
#      http_error 500
#    end
#  end

  def envs_to_request_as_smart_phone
    return @envs_to_request_as_smart_phone if @envs_to_request_as_smart_phone
    user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D201 Safari/9537.53'
    jpmobile = Jpmobile::Mobile::AbstractMobile.carrier('HTTP_USER_AGENT' => user_agent)
    @envs_to_request_as_smart_phone = {'HTTP_USER_AGENT' => user_agent, 'rack.jpmobile' => jpmobile}
  end

  def request_as_mobile
    user_agent = 'DoCoMo/2.0 ISIM0808(c500;TB;W24H16)'
    env['rack.jpmobile'] = Jpmobile::Mobile::AbstractMobile.carrier('HTTP_USER_AGENT' => user_agent)
  end
end
