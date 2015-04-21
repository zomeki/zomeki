class Cms::Public::ApiController < Cms::Controller::Public::Base
  include Cms::ApiCommon
  include Cms::ApiAdBanner
  include Cms::ApiGpCalendar
  include Cms::ApiRank

  skip_filter :render_public_layout

  def receive
    return render_404 if (api_path = params[:api_path].to_s).blank? ||
                         (version = params[:version].to_s).blank?
    path = api_path.split('/')
    case path.shift
    when 'authenticity_token'; render(json: {authenticity_token: form_authenticity_token})
    when 'ad_banner'; ad_banner(path: path, version: version)
    when 'gp_calendar'; gp_calendar(path: path, version: version)
    when 'rank'; rank(path: path, version: version)
    else render_404
    end
  end
end
