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
      Page.mobile = nil
      unset_mobile
    else
      Page.mobile = true if request.mobile?
      set_mobile if Page.mobile? && !request.mobile?
    end
    return false if Core.dispatched?
    return Core.dispatched
  end
  
  def query(params = nil)
    Util::Http::QueryString.get_query(params)
  end
  
  def send_mail(fr_addr, to_addr, subject, body)
    return false if fr_addr.blank?
    return false if to_addr.blank?
    DefaultMailer::Mail.deliver(fr_addr, to_addr, subject, body)
  end
  
  def send_download
    #
  end
  
  def set_mobile
    def request.mobile
      Jpmobile::Mobile::Au.new(nil, self)
    end
  end
  
  def unset_mobile
    def request.mobile
      nil
    end
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
    
    if Core.mode =~ /^(admin|script)$/ && status != 404
      error_log("#{status} #{request.env['REQUEST_URI']}") if status != 404
      return respond_to do |format|
        format.html { render :status => status, :text => "<p>#{message}</p>", :layout => "admin/cms/error" }
        format.xml  { render :status => status, :xml => "<errors><error>#{message}</error></errors>" }
      end
    end
    
    ## Render
    html = nil
    if Page.site && FileTest.exist?("#{Page.site.public_path}/#{status}.html")
      html = ::File.new("#{Page.site.public_path}/#{status}.html").read
    elsif Core.site && FileTest.exist?("#{Core.site.public_path}/#{status}.html")
      html = ::File.new("#{Core.site.public_path}/#{status}.html").read
    elsif FileTest.exist?("#{Rails.public_path}/#{status}.html")
      html = ::File.new("#{Rails.public_path}/#{status}.html").read
    elsif FileTest.exist?("#{Rails.public_path}/500.html")
      html = ::File.new("#{Rails.public_path}/500.html").read
    else
      html = "<html>\n<head></head>\n<body>\n<p>#{message}</p>\n</body>\n</html>\n"
    end
    
    return respond_to do |format|
      format.html { render :status => status, :inline => html }
      format.xml  { render :status => status, :xml => "<errors><error>#{message}</error></errors>" }
    end
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
end
