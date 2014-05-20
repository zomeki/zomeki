# encoding: utf-8
class Map::Admin::CategoryTypesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_filter :get_item_and_setting, :only => [ :edit, :update ]

  def pre_dispatch
    return error_auth unless @content = Map::Content::Marker.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.category_types.paginate(page: params[:page], per_page: 50)
  end

  def edit
    @icon_image = @setting.value
  end

  def update
    @setting.value = params[:icon_image]
    _update @setting
  end

  private

  def get_item_and_setting
    @item = @content.category_types.find(params[:id])
    @setting = Map::Content::Setting.config(@content, "#{@item.class.name} #{@item.id} icon_image")
  end
end
