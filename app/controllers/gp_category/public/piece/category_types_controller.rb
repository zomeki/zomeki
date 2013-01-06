# encoding: utf-8
class GpCategory::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_piece.content_id)
    return http_error(404) unless @content
  end

  def index
    @item = Page.current_item
  end
end
