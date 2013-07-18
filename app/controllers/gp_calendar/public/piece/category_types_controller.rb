# encoding: utf-8
class GpCalendar::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCalendar::Piece::CategoryType.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece
    @content = GpCalendar::Content::Event.find_by_id(@piece.content.id)
    render :text => '' unless @content

    @item = Page.current_item
  end

  def index
  end
end
