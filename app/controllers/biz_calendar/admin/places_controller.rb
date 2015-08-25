# encoding: utf-8
class BizCalendar::Admin::PlacesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = BizCalendar::Content::Place.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    item = BizCalendar::Place.new
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order 'sort_no, updated_at DESC, id DESC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = BizCalendar::Place.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = @content.places.build
  end

  def create
    @item = @content.places.build(params[:item])
    _create(@item)
  end

  def update
    @item = @content.places.find(params[:id])
    @item.attributes = params[:item]
    _update(@item)
  end

  def destroy
    @item = @content.places.find(params[:id])
    _destroy @item
  end

end
