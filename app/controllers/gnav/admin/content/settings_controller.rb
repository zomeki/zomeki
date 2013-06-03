# encoding: utf-8
class Gnav::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Gnav::Content::MenuItem.find(params[:content])
    return error_auth unless @content.editable?
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = Gnav::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = Gnav::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def update
    @item = Gnav::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    _update @item
  end
end
