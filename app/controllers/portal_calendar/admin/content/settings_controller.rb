# encoding: utf-8
class PortalCalendar::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless @content.editable?
#    default_url_options :content => @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = PortalCalendar::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = PortalCalendar::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = PortalCalendar::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    _update(@item)
  end

  def destroy
    error_auth
  end
end
