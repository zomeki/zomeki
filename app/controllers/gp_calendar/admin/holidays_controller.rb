# encoding: utf-8
class GpCalendar::Admin::HolidaysController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include GpCalendar::Controller::Holiday

  def pre_dispatch
    return error_auth unless @content = GpCalendar::Content::Event.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    create_default_holidays(@content)

    @items = @content.holidays.order("date_format(date,'%m%d')").paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @content.holidays.find(params[:id])
    _show @item
  end

  def new
    @item = @content.holidays.build
  end

  def create
    @item = @content.holidays.build(params[:item])
    @item.date = parse_date(params[:item][:date])
    _create @item
  end

  def update
    @item = @content.holidays.find(params[:id])
    @item.attributes = params[:item]
    @item.date = parse_date(params[:item][:date])
    _update @item
  end

  def destroy
    @item = @content.holidays.find(params[:id])
    _destroy @item
  end

end
