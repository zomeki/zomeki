# encoding: utf-8
class GpCategory::Admin::CategoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = GpCategory::Content::CategoryType.find_by_id(params[:content])
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    return error_auth unless @category_type = GpCategory::CategoryType.find_by_id(params[:category_type_id])
    @parent_category = @category_type.categories.find_by_id(params[:category_id])
  end

  def index
    if params[:options]
      render 'index_options', :layout => false
    else
      if @parent_category
        @items = @parent_category.children.paginate(page: params[:page], per_page: 50)
      else
        @items = @category_type.root_categories.paginate(page: params[:page], per_page: 50)
      end
      _index @items
    end
  end

  def show
    @item = @category_type.categories.find(params[:id])
    _show @item
  end

  def new
    @item = @category_type.categories.build(state: 'public', sort_no: 10)
  end

  def create
    @item = @category_type.categories.build(params[:item])
    @item.parent = @parent_category if @parent_category
    _create @item
  end

  def edit
    @item = @category_type.categories.find(params[:id])
  end

  def update
    @item = @category_type.categories.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @category_type.categories.find(params[:id])
    _destroy @item
  end
end
