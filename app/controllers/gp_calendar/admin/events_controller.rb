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
    _create(@item) do
      set_categories
      @item.fix_tmp_files(params[:_tmp])
    end
  end

  def update
    @item = @content.events.find(params[:id])
    @item.attributes = params[:item]
    _update(@item) do
      set_categories
    end
  end

  def destroy
    @item = @content.events.find(params[:id])
    _destroy @item
  end

  private

  def set_categories
    category_ids = (params[:categories] || []).map{|id| id.to_i if id.present? }.compact.uniq
    @item.category_ids = category_ids
  end
end
