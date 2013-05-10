# encoding: utf-8
class AdBanner::Public::Piece::BannersController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = AdBanner::Piece::Banner.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece
  end

  def index
  end
end
