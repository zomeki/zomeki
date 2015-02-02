class Cms::Public::ApiController < Cms::Controller::Public::Base
  include Cms::ApiGpCalendar

  skip_filter :render_public_layout

  def receive
    return render_404 if (api_path = params[:api_path].to_s).blank? ||
                         (version = params[:version].to_s).blank?
    path = api_path.split('/')
    case path.shift
    when 'gp_calendar'; gp_calendar(path: path, version: version)
    else render_404
    end
  end

  private

  def render_404
    render text: '404 Not Found', status: 404
  end

  def render_405
    render text: '405 Method Not Allowed', status: 405
  end
end
