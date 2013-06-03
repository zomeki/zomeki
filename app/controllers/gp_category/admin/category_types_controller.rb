# encoding: utf-8
class GpCategory::Admin::CategoryTypesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = GpCategory::Content::CategoryType.find_by_id(params[:content])
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    if params[:check_boxes]
      @items = @content.category_types
      render 'index_check_boxes', :layout => false
    elsif params[:options]
      @items = @content.category_types
      render 'index_options', :layout => false
    else
      @items = @content.category_types.paginate(page: params[:page], per_page: 50)
      _index @items
    end
  end

  def show
    @item = GpCategory::CategoryType.find(params[:id])
    _show @item
  end

  def new
    @item = GpCategory::CategoryType.new(state: 'public', sort_no: 10)
  end

  def create
    @item = GpCategory::CategoryType.new(params[:item])
    @item.concept = @content.concept
    @item.content = @content
    @item.in_creator = {'group_id' => Core.user_group.id, 'user_id' => Core.user.id}
    _create @item
  end

  def edit
    @item = GpCategory::CategoryType.find(params[:id])
  end

  def update
    @item = GpCategory::CategoryType.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = GpCategory::CategoryType.find(params[:id])
    _destroy @item
  end
end
