# encoding: utf-8
class GpCategory::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_piece.content_id)
    @node = @content.try(:category_type_node)
    return http_error(404) unless @node
  end

  def index
    case (@item = Page.current_item)
    when GpCategory::CategoryType
      @items = @item.root_categories
    end
  end
end
