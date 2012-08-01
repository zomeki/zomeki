# encoding: utf-8
class PortalArticle::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless @content.editable?
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = PortalArticle::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = PortalArticle::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = PortalArticle::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    
    _update(@item) do
      case @item.name
      when "portal_group_id"
        values = {:portal_group_id => @item.value}
        cond   = {:content_id => @item.content_id}
        PortalArticle::Doc.update_all(values, cond)
      end
    end
  end

  def destroy
    error_auth
  end
end
