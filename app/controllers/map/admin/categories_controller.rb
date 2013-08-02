# encoding: utf-8
class Map::Admin::CategoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Map::Content::Marker.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)

    return error_auth unless @category_type = @content.category_types.find_by_id(params[:category_type_id])
    @parent_category = @category_type.categories.find_by_id(params[:category_id])
  end

  def index
    @items = if @parent_category
               @parent_category.children.paginate(page: params[:page], per_page: 50)
             else
               @category_type.categories.where(id: @content.categories.pluck(:id)).paginate(page: params[:page], per_page: 50)
             end
  end

  def edit
    @item = @category_type.categories.find(params[:id])
  end

  def update
    @item = @category_type.categories.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
end
