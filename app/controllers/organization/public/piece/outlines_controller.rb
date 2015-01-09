class Organization::Public::Piece::OutlinesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Organization::Piece::Outline.where(id: Page.current_piece.id).first
    return render(text: '') unless @piece

    @item = Page.current_item
  end

  def index
    render text: @item.outline
  end
end
