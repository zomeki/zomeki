# encoding: utf-8
class Gnav::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gnav::Piece::CategoryType.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    unless @piece.category_type
      piece_categories = @piece.category_types.inject([]) {|result, ct| result | ct.categories }
    else
      piece_categories = @piece.categories
    end

    case @item
    when Gnav::MenuItem
      page_categories = @item.categories
    end

    if page_categories
      @categories = piece_categories & page_categories
    else
      @categories = piece_categories
    end
  end
end
