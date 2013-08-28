# encoding: utf-8
class Rank::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Rank::Content::Rank.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = Rank::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = Rank::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def edit
    @item = Rank::Content::Setting.config(@content, params[:id])
  end

  def update
    @item = Rank::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    _update @item
  end
end
