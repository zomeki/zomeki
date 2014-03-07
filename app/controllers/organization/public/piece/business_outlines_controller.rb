class Organization::Public::Piece::BusinessOutlinesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Organization::Piece::BusinessOutline.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
  end
end
