# encoding: utf-8
class Gnav::Admin::MenuItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Gnav::Content::MenuItem.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = @content.menu_items.paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @content.menu_items.find(params[:id])
    _show @item
  end

  def new
    @item = @content.menu_items.build(state: 'public', sort_no: 10)
  end

  def create
    @item = @content.menu_items.build(params[:item])
    _create @item
  end

  def update
    @item = @content.menu_items.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @content.menu_items.find(params[:id])
    _destroy @item
  end
end
