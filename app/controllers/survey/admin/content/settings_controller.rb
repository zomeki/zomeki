# encoding: utf-8
class Survey::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Survey::Content::Form.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = Survey::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = Survey::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def update
    @item = Survey::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]

    @item.extra_values do |ev|
      ev[:approval_content_id] = params[:approval_content_id].to_i
    end

    _update @item
  end
end
