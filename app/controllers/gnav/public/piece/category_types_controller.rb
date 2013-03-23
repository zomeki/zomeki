# encoding: utf-8
class Gnav::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gnav::Piece::CategoryType.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    piece_categories = @piece.public_categories

    case @item
    when Gnav::MenuItem
      page_categories = @item.categories
    end

    if page_categories
      @categories = piece_categories & page_categories
    else
      @categories = piece_categories
    end

    @least_level_no = @categories.min{|a, b| a.level_no <=> b.level_no }.level_no
    @categories.reject! {|c| c.level_no > (@least_level_no + 1) }
  end
end
