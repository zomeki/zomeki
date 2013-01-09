# encoding: utf-8
class GpCategory::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::CategoryType.find_by_id(Page.current_piece.id)
    return http_error(404) unless @piece
  end

  def index
    @item = Page.current_item
  end
end
