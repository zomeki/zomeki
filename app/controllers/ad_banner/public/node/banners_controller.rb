# encoding: utf-8
class AdBanner::Public::Node::BannersController < Cms::Controller::Public::Base
  skip_filter :render_public_layout, :only => :index

  def pre_dispatch
    @content = AdBanner::Content::Banner.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    filename = (params[:file_base].present? && params[:file_ext].present? ? "#{params[:file_base]}.#{params[:file_ext]}" : nil)
    token = params[:token].presence

    if (banner_token = params[:i]).present? || filename.present?
      banner = @content.banners.find_by_token(banner_token) || @content.banners.find_by_name(filename)
      return http_error(404) unless banner

      mt = banner.mime_type.presence || Rack::Mime.mime_type(File.extname(banner.name))
      type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
      disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
      send_file banner.upload_path, :type => type, :filename => banner.name, :disposition => disposition
    elsif (banner_token = params[:r]).present? || token.present?
      @banner = @content.banners.find_by_token(banner_token) || @content.banners.find_by_token(token)
      return http_error(404) unless @banner

      clicks = AdBanner::Click.arel_table
# Accept all clicks
#      click = @banner.clicks.where(clicks[:remote_addr].eq(request.remote_addr).and(clicks[:created_at].gteq(30.minutes.ago))).first
#      @banner.clicks.create(referer: request.referer, remote_addr: request.remote_addr, user_agent: request.user_agent) unless click
      @banner.clicks.create(referer: request.referer, remote_addr: request.remote_addr, user_agent: request.user_agent)

      redirect_to @banner.url
    else
      http_error(404)
    end
  end
end
