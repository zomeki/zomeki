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
    set_categories
    _create @item
  end

  def update
    @item = GpCategory::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    @item.attributes = params[:item]
    set_categories
    _update @item
  end

  def destroy
    @item = GpCategory::Piece::RecentTabXml.find(params[:id], @piece)
    _destroy @item
  end

  private

  def set_categories
    if (categories = params[:categories]).is_a?(Array)
      category_ids = {}
      categories.each_with_index {|category, index| category_ids[index.to_s] = category.to_s }
      @item.category_ids = category_ids
    end
  end
end
