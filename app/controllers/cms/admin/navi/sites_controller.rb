class Cms::Admin::Navi::SitesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def index
    if current_user.root?
      item = Cms::Site.new
      @sites = item.find(:all, :order => :id)
    else
      # システム管理者以外は所属サイトしか操作できない
      @sites = current_user.sites
    end

    no_ajax = request.env['HTTP_X_REQUESTED_WITH'].to_s !~ /XMLHttpRequest/i
    render :layout => no_ajax
  end
  
  def show
    render :text => ""
  end
end
