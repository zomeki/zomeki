# encoding: utf-8
class GpArticle::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless @content.editable?
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = GpArticle::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = GpArticle::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def edit
    @item = GpArticle::Content::Setting.config(@content, params[:id])
  end

  def update
    @item = GpArticle::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]

    if @item.name == 'gp_category_content_category_type_id'
      @item.extra_value = params[:category_types].try(:join, ',')
    end

    _update @item
  end
end
