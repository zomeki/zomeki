# encoding: utf-8
class Map::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Map::Piece::CategoryType.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    @top_categories = @piece.content.public_categories
  end
end
