class Cms::Public::Piece::SnsPartsController < Sys::Controller::Public::Base
  def pre_dispatch
    render :text => '' unless @piece = Cms::Piece::SnsPart.find_by_id(Page.current_piece.id)
  end
end
