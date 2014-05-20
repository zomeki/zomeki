# encoding: utf-8
class GpTemplate::Admin::ItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = GpTemplate::Content::Template.find_by_id(params[:content])
    return error_auth unless @template = @content.templates.find_by_id(params[:template_id])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @template.items.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @template.items.find(params[:id])
    _show @item
  end

  def new
    @item = @template.items.build
  end

  def create
    @item = @template.items.build(params[:item])
    _create @item
  end

  def update
    @item = @template.items.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @template.items.find(params[:id])
    _destroy @item
  end
end
