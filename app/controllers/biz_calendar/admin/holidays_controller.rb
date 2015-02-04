# encoding: utf-8
class BizCalendar::Admin::HolidaysController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = BizCalendar::Content::Place.find_by_id(params[:content])
    return error_auth unless @place = @content.places.find_by_id(params[:place_id])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @place.holidays.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @place.holidays.find(params[:id])
    _show @item
  end

  def new
    @item = @place.holidays.build
  end

  def create
    @item = @place.holidays.build(params[:item])
    _create @item
  end

  def update
    @item = @place.holidays.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @place.holidays.find(params[:id])
    _destroy @item
  end
end
