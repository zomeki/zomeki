# encoding: utf-8
class Map::Admin::CategoryTypesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Map::Content::Marker.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.category_types.paginate(page: params[:page], per_page: 50)
  end

  def edit
    @item = @content.category_types.find(params[:id])
  end

  def update
    @item = @content.category_types.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
end
