# encoding: utf-8
class GpCategory::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::CategoryType.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    case @item
    when GpCategory::CategoryType
      @category_type = @item
      render :category_type
    when GpCategory::Category
      @category = @item
      render :category
    else
      @category_types = @piece.public_category_types
    end
  end
end
