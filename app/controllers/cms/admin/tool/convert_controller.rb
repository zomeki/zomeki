# encoding: utf-8
class Cms::Admin::Tool::ConvertController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
  end

  def index
    @item  = []
    def @item.site_url ; @site_url ; end
    def @item.site_url=(v) ; @site_url = v ; end
    if request.post?
      @item.site_url= params[:item][:site_url]
      # TODO dairg download the site
      Util::Convert.download_site(@item.site_url)
      redirect_to tool_convert_url
    end
  end
end

