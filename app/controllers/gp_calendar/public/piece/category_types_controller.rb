# encoding: utf-8
class GpCalendar::Public::Piece::CategoryTypesController < GpCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = GpCalendar::Piece::CategoryType.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    @top_categories = @piece.content.public_categories
  end
end
