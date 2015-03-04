# encoding: utf-8
class GpCategory::Admin::Piece::RecentTabs::TabsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @piece = GpCategory::Piece::RecentTab.find_by_id(params[:piece_recent_tab_id])
    return error_auth unless @piece.editable?
  end

  def index
    @items = GpCategory::Piece::RecentTabXml.find(:all, @piece, :order => :sort_no)
    _index @items
  end

  def show
    @item = GpCategory::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    _show @item
  end

  def new
    @item = GpCategory::Piece::RecentTabXml.new(@piece, condition: GpCategory::Piece::RecentTabXml::CONDITION_OPTIONS.first.last, sort_no: 0)
  end

  def create
    @item = GpCategory::Piece::RecentTabXml.new(@piece, params[:item])
    set_elements
    _create @item
  end

  def update
    @item = GpCategory::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    @item.attributes = params[:item]
    set_elements
    _update @item
  end

  def destroy
    @item = GpCategory::Piece::RecentTabXml.find(params[:id], @piece)
    _destroy @item
  end

  private

  def set_elements
    @item.elem_category_ids = params[:categories]

    elem_layers = {}
    params[:layers].each {|k, v| elem_layers[k] = "#{k}_#{v}" }
    @item.elem_layers = elem_layers
  end
end
