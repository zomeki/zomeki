# encoding: utf-8
class Map::Admin::MarkersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Map::Content::Marker.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.markers.paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @content.markers.find(params[:id])
    _show @item
  end

  def new
    @item = @content.markers.build
  end

  def create
    @item = @content.markers.build(params[:item])
    _create(@item) do
      set_categories
    end
  end

  def update
    @item = @content.markers.find(params[:id])
    @item.attributes = params[:item]
    _update(@item) do
      set_categories
    end
  end

  def destroy
    @item = @content.markers.find(params[:id])
    _destroy @item
  end

  private

  def set_categories
    category_ids = if params[:categories].kind_of?(Hash)
                     params[:categories].values.flatten.reject{|c| c.blank? }.uniq
                   else
                     []
                   end
    @item.category_ids = category_ids
  end
end
