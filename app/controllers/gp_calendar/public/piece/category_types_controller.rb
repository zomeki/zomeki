# encoding: utf-8
class GpCalendar::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCalendar::Piece::CategoryType.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
  end
end
