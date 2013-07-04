# encoding: utf-8
class GpCalendar::Admin::EventsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = GpCalendar::Content::Event.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['REQUEST_PATH']) if params[:reset_criteria]
  end

  def index
    criteria = params[:criteria] || {}
    @items = GpCalendar::Event.all_with_content_and_criteria(@content, criteria).paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @content.events.find(params[:id])
    _show @item
  end

  def new
    @item = @content.events.build
  end

  def create
    @item = @content.events.build(params[:item])
    _create @item
  end

  def update
    @item = @content.events.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @content.events.find(params[:id])
    _destroy @item
  end
end
