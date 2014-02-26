class Organization::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Organization::Content::Group.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = Organization::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = Organization::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def update
    @item = Organization::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    _update @item
  end
end
