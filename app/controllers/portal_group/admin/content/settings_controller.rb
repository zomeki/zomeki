# encoding: utf-8
class PortalGroup::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless @content.editable?
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = PortalGroup::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = PortalGroup::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = PortalGroup::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    _update(@item)
  end

  def destroy
    error_auth
  end
end
